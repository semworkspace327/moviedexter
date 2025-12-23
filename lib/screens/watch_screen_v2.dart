import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

class WatchScreen extends StatefulWidget {
  final int movieId;
  final int? season;
  final int? episode;
  final String title;
  final bool isTvShow;

  const WatchScreen({
    super.key,
    required this.movieId,
    required this.title,
    this.season,
    this.episode,
    this.isTvShow = false,
  });

  @override
  State<WatchScreen> createState() => _WatchScreenState();
}

class _WatchScreenState extends State<WatchScreen> {
  bool _isLoading = true;
  bool _isFullscreen = false;
  final AdService _adService = AdService();

  @override
  void initState() {
    super.initState();
    _adService.loadNativeAd();
  }

  @override
  void dispose() {
    _adService.disposeNativeAd();
    // Restore portrait mode on dispose
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    // Show interstitial ad when leaving player
    final adService = AdService();
    await adService.showInterstitialAd();
    return true;
  }

  // Build the embed URL based on the API documentation
  String get _embedUrl {
    const baseUrl = 'https://vidsrc-embed.ru/embed';

    if (widget.isTvShow) {
      // TV show or episode
      if (widget.season != null && widget.episode != null) {
        // Episode URL: /embed/tv/{tmdb}/{season}-{episode}?autoplay=1
        return '$baseUrl/tv/${widget.movieId}/${widget.season}-${widget.episode}?autoplay=1';
      } else {
        // TV show URL: /embed/tv/{tmdb}?autoplay=1
        return '$baseUrl/tv/${widget.movieId}?autoplay=1';
      }
    } else {
      // Movie URL: /embed/movie/{tmdb}?autoplay=1
      return '$baseUrl/movie/${widget.movieId}?autoplay=1';
    }
  }

  // Anti-detection JavaScript to inject BEFORE page loads
  final String _antiDetectionScript = """
    (function() {
      // Override DisableDevtool before it can be defined
      window.DisableDevtool = function() {
        console.log('🛡️ DisableDevtool blocked');
      };
      
      // Prevent the library from being loaded
      Object.defineProperty(window, 'DisableDevtool', {
        get: function() { 
          return function() {};
        },
        set: function() {
          console.log('🛡️ Blocked DisableDevtool setter');
        }
      });

      // Override common WebView detection properties
      Object.defineProperty(navigator, 'webdriver', {
        get: () => false
      });

      // Clear any devtools detection intervals
      const originalSetInterval = window.setInterval;
      window.setInterval = function(fn, delay) {
        const fnString = fn.toString();
        if (fnString.includes('devtool') || fnString.includes('DisableDevtool')) {
          console.log('🛡️ Blocked devtools detection interval');
          return -1;
        }
        return originalSetInterval.apply(window, arguments);
      };

      // POPUP BLOCKING - Less aggressive, only block window.open
      const originalOpen = window.open;
      window.open = function() {
        console.log('🚫 Blocked popup via window.open');
        // Return a fake window object to not break detection
        return {
          closed: false,
          close: function() {},
          focus: function() {},
          blur: function() {},
          location: { href: '' }
        };
      };

      // Preserve the toString to avoid detection
      window.open.toString = function() {
        return 'function open() { [native code] }';
      };

      // CLICK EVENT DEBUGGING - Monitor clicks to diagnose issues
      document.addEventListener('click', function(e) {
        console.log('🖱️ Click detected on:', e.target.tagName, e.target.className);
      }, true);

      document.addEventListener('touchstart', function(e) {
        console.log('👆 Touch detected on:', e.target.tagName);
      }, true);

      // FORCE AUTOPLAY - Click play button automatically
      function forceAutoplay() {
        // Find and click any play buttons
        const playButtons = document.querySelectorAll('button[aria-label*="play" i], button[title*="play" i], .play-button, [class*="play"], [id*="play"]');
        playButtons.forEach(btn => {
          if (btn.offsetParent !== null && !btn.disabled) {
            console.log('🎬 Auto-clicking play button');
            btn.click();
          }
        });

        // Find video elements and try to play them
        const videos = document.querySelectorAll('video');
        videos.forEach(video => {
          if (video.paused) {
            console.log('🎬 Auto-playing video element');
            video.play().catch(e => console.log('⚠️ Autoplay prevented:', e));
          }
        });

        // Find iframes and try to trigger play
        const iframes = document.querySelectorAll('iframe');
        iframes.forEach(iframe => {
          try {
            if (iframe.contentWindow) {
              const iframeVideos = iframe.contentWindow.document.querySelectorAll('video');
              iframeVideos.forEach(video => {
                if (video.paused) {
                  console.log('🎬 Auto-playing iframe video');
                  video.play().catch(e => console.log('⚠️ Iframe autoplay prevented:', e));
                }
              });
            }
          } catch (e) {
            // Cross-origin iframe, can't access
          }
        });
      }

      // Try autoplay immediately and repeatedly
      setTimeout(forceAutoplay, 500);
      setTimeout(forceAutoplay, 1000);
      setTimeout(forceAutoplay, 2000);
      setTimeout(forceAutoplay, 3000);
      setInterval(forceAutoplay, 5000);

      // Remove ad overlays that might block the video player AND CLICKS
      function removeAdOverlays() {
        // Remove elements that cover the entire screen or block clicks
        document.querySelectorAll('[id*="ad"], [class*="ad"], [id*="popup"], [class*="popup"], [class*="overlay"]').forEach(el => {
          const style = window.getComputedStyle(el);
          if (style.position === 'fixed' || style.position === 'absolute') {
            const rect = el.getBoundingClientRect();
            // If element covers most of the screen or has high z-index, remove it
            if ((rect.width > window.innerWidth * 0.8 && rect.height > window.innerHeight * 0.8) ||
                parseInt(style.zIndex) > 1000) {
              console.log('🚫 Removed ad/click overlay:', el.className);
              el.remove();
            }
          }
        });

        // Remove elements with pointer-events that might block clicks
        document.querySelectorAll('*').forEach(el => {
          const style = window.getComputedStyle(el);
          // Check if element is blocking clicks but invisible
          if (style.pointerEvents !== 'none' && 
              (style.position === 'fixed' || style.position === 'absolute')) {
            const rect = el.getBoundingClientRect();
            if (rect.width > window.innerWidth * 0.9 && 
                rect.height > window.innerHeight * 0.9 &&
                (style.opacity === '0' || style.visibility === 'hidden' || style.display === 'none')) {
              console.log('🚫 Removed invisible click blocker');
              el.style.pointerEvents = 'none';
            }
          }
        });
      }

      // Run periodically to catch dynamically added overlays
      setInterval(removeAdOverlays, 1000);

      console.log('🛡️ Anti-detection script loaded (clicks enabled, overlays removed)');
    })();
  """;

  void _enterFullscreen() {
    setState(() {
      _isFullscreen = true;
    });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  void _exitFullscreen() {
    setState(() {
      _isFullscreen = false;
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final userScript = UserScript(
      source: _antiDetectionScript,
      injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
      forMainFrameOnly: false,
    );

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          await _onWillPop();
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Column(
              children: [
                _buildHeader(context),
                // Top half - Video player WebView
                Expanded(flex: 1, child: _buildWebView(userScript)),
                // Bottom half - Native Ad
                if (!_isFullscreen)
                  Expanded(flex: 1, child: _buildNativeAdSection()),
              ],
            ),
            if (_isLoading) _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.8), Colors.transparent],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Back Button
                IconButton(
                  onPressed: () async {
                    await _onWillPop();
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                // Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.isTvShow &&
                          widget.season != null &&
                          widget.episode != null)
                        Text(
                          'S${widget.season}E${widget.episode.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebView(UserScript userScript) {
    return Stack(
      children: [
        InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri(_embedUrl),
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1',
              'Accept':
                  'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
              'Accept-Language': 'en-US,en;q=0.9',
            },
          ),
          initialUserScripts: UnmodifiableListView<UserScript>([userScript]),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            mediaPlaybackRequiresUserGesture: false,
            allowsInlineMediaPlayback: true,
            iframeAllow:
                "autoplay; camera; microphone; encrypted-media; fullscreen",
            allowsAirPlayForMediaPlayback: true,
            domStorageEnabled: true,
            databaseEnabled: true,
            cacheEnabled: true,
            javaScriptCanOpenWindowsAutomatically: false,
            supportMultipleWindows: false,
            mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
            // Enable user interactions - critical for click events
            disableContextMenu: false,
            allowsBackForwardNavigationGestures: false,
            disableLongPressContextMenuOnLinks: false,
            // Ensure touch events are enabled
            userAgent:
                'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1',
          ),
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            final uri = navigationAction.request.url;
            if (uri == null) return NavigationActionPolicy.CANCEL;

            final url = uri.toString();
            final host = uri.host.toLowerCase();

            // Block the disable-devtool script
            if (url.contains('unpkg.com/disable-devtool') ||
                url.contains('disable-devtool.min.js')) {
              debugPrint('🛡️ Blocked disable-devtool script: $url');
              return NavigationActionPolicy.CANCEL;
            }

            // Block common ad networks and popup domains
            final blockedPatterns = [
              'doubleclick.net',
              'googlesyndication.com',
              'adserver',
              'ads.',
              'advertis',
              'popup',
              'popunder',
              '/ads/',
              'ad.php',
              'track.',
              'analytics',
              'click.',
              '/click',
              'redirect',
              'promo',
            ];

            for (final pattern in blockedPatterns) {
              if (host.contains(pattern) || url.contains(pattern)) {
                debugPrint('🚫 Blocked ad/popup URL: $url');
                return NavigationActionPolicy.CANCEL;
              }
            }

            // Allow vidsrc and cloudnestra domains (legitimate video sources)
            final allowedDomains = ['vidsrc', 'cloudnestra'];

            bool isAllowed = allowedDomains.any(
              (domain) => host.contains(domain),
            );

            if (!isAllowed &&
                navigationAction.navigationType ==
                    NavigationType.LINK_ACTIVATED) {
              // Block navigation to external sites via links (popups)
              debugPrint('🚫 Blocked external navigation: $url');
              return NavigationActionPolicy.CANCEL;
            }

            // Allow navigation
            return NavigationActionPolicy.ALLOW;
          },
          onCreateWindow: (controller, createWindowAction) async {
            // Block ALL new window creation (popups)
            debugPrint('🚫 Blocked new window creation');
            return false;
          },
          onLoadStop: (controller, url) {
            setState(() {
              _isLoading = false;
            });
            debugPrint('✅ Page loaded: $url');
          },
          onLoadStart: (controller, url) {
            debugPrint('🔄 Loading: $url');
          },
          onConsoleMessage: (controller, consoleMessage) {
            debugPrint('📝 Console: ${consoleMessage.message}');
          },
          onEnterFullscreen: (controller) {
            debugPrint('📺 Entered fullscreen');
            _enterFullscreen();
          },
          onExitFullscreen: (controller) {
            debugPrint('📺 Exited fullscreen');
            _exitFullscreen();
          },
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              const Text(
                'Loading Video...',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNativeAdSection() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          Container(height: 1, color: Colors.grey.withAlpha(51)),
          Expanded(
            child: _adService.isNativeAdReady
                ? _buildNativeAd()
                : _buildAdLoadingPlaceholder(),
          ),
        ],
      ),
    );
  }

  Widget _buildNativeAd() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 320,
            minHeight: 320,
            maxWidth: 400,
            maxHeight: 400,
          ),
          child: AdWidget(ad: _adService.nativeAd!),
        ),
      ),
    );
  }

  Widget _buildAdLoadingPlaceholder() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withAlpha(76),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading Ad...',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

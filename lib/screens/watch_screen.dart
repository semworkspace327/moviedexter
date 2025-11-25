import 'dart:collection';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Watch screen for streaming movies and TV shows
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
  bool _hasError = false;
  String _errorMessage = "";

  InAppWebViewController? _webViewController;

  // JavaScript to remove sandbox attribute from iframes
  final String _jsRemoveSandboxScript = """
    function removeSandbox() {
        var iframes = document.getElementsByTagName('iframe');
        for (var i = 0; i < iframes.length; i++) {
            iframes[i].removeAttribute('sandbox');
        }
    }

    removeSandbox();

    var observer = new MutationObserver(function(mutations) {
        mutations.forEach(function(mutation) {
            mutation.addedNodes.forEach(function(node) {
                if (node.tagName === 'IFRAME') {
                    node.removeAttribute('sandbox');
                }
            });
        });
    });

    if (document.body) {
        observer.observe(document.body, { childList: true, subtree: true });
    } else {
        document.addEventListener('DOMContentLoaded', function() {
            removeSandbox();
            observer.observe(document.body, { childList: true, subtree: true });
        });
    }
  """;

  // User agents for rotation
  final List<String> _userAgents = [
    "Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1",
    "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1",
    "Mozilla/5.0 (iPad; CPU OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Safari/605.1.15",
  ];

  String _getRandomUserAgent() {
    return _userAgents[Random().nextInt(_userAgents.length)];
  }

  String get _embedUrl {
    final baseUrl =
        widget.isTvShow && widget.season != null && widget.episode != null
        ? 'https://vidfast.pro/tv/${widget.movieId}/${widget.season}/${widget.episode}'
        : 'https://vidfast.pro/movie/${widget.movieId}';

    // Add parameters for better experience
    final params = <String, String>{
      'autoPlay': 'true',
      'title': 'false',
      'poster': 'false',
      'fullscreenButton': 'true',
      'chromecast': 'true',
      'sub': 'en',
    };

    // Add TV-specific parameters
    if (widget.isTvShow) {
      params['nextButton'] = 'true';
      params['autoNext'] = 'true';
    }

    final queryString = params.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    return '$baseUrl?$queryString';
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(context),
              // Full screen WebView
              Expanded(
                child: _hasError ? _buildErrorSection() : _buildWebView(),
              ),
            ],
          ),
          if (_isLoading) _buildLoadingOverlay(),
        ],
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
                  onPressed: () => Navigator.pop(context),
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

  Widget _buildWebView() {
    final randomUserAgent = _getRandomUserAgent();
    final urlRequest = URLRequest(
      url: WebUri(_embedUrl),
      headers: {
        'Referer': 'https://vidfast.pro',
        'Origin': 'https://vidfast.pro',
        'User-Agent': randomUserAgent,
      },
    );

    final userScript = UserScript(
      source: _jsRemoveSandboxScript,
      injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
      forMainFrameOnly: false,
    );

    return InAppWebView(
      initialUrlRequest: urlRequest,
      initialUserScripts: UnmodifiableListView<UserScript>([userScript]),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        javaScriptCanOpenWindowsAutomatically: false,
        allowsInlineMediaPlayback: true,
        mediaPlaybackRequiresUserGesture: false,
        allowsPictureInPictureMediaPlayback: true,
        cacheEnabled: true,
        allowsBackForwardNavigationGestures: false,
        allowsLinkPreview: false,
        userAgent: randomUserAgent,
        transparentBackground: false,
      ),
      onWebViewCreated: (controller) async {
        _webViewController = controller;
      },
      onLoadStart: (controller, url) {
        setState(() {
          _isLoading = true;
          _hasError = false;
        });
      },
      onLoadStop: (controller, url) {
        setState(() {
          _isLoading = false;
        });
      },
      onLoadError: (controller, url, code, message) {
        if (code == -999) return; // Ignore cancelled errors
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = "Error loading video";
        });
      },
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        final uri = navigationAction.request.url;
        if (uri == null) return NavigationActionPolicy.CANCEL;

        final allowedHosts = [
          'vidfast.pro',
          'vidfast.in',
          'vidfast.io',
          'vidfast.me',
          'vidfast.net',
          'vidfast.pm',
          'vidfast.xyz',
        ];

        bool isAllowed = allowedHosts.any((host) => uri.host.contains(host));

        if (isAllowed) {
          return NavigationActionPolicy.ALLOW;
        } else {
          if (_isLoading) {
            setState(() => _isLoading = false);
          }
          return NavigationActionPolicy.CANCEL;
        }
      },
      onCreateWindow: (controller, createWindowAction) async => false,
      onJsAlert: (controller, jsAlertRequest) async {
        return JsAlertResponse(
          handledByClient: true,
          action: JsAlertResponseAction.CONFIRM,
        );
      },
    );
  }

  Widget _buildErrorSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          const Text(
            'Unable to Load Video',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage.isEmpty
                ? 'There was an error loading the video. Please try again.'
                : _errorMessage,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _hasError = false;
                _isLoading = true;
              });
              _webViewController?.reload();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
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
}

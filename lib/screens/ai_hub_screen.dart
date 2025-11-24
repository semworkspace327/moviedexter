import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../services/ad_service.dart';

class AIHubScreen extends ConsumerStatefulWidget {
  const AIHubScreen({super.key});

  @override
  ConsumerState<AIHubScreen> createState() => _AIHubScreenState();
}

class _AIHubScreenState extends ConsumerState<AIHubScreen> {
  Widget? _currentView;

  void _navigateToTool(Widget toolWidget) {
    setState(() {
      _currentView = toolWidget;
    });
  }

  void _goBack() {
    setState(() {
      _currentView = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A0E27), Color(0xFF1A1F3A), Color(0xFF2D1B4E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text(
            'Movie Dexter',
            style: TextStyle(
              color: Color(0xFFFFD233),
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: _currentView != null
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: _goBack,
                )
              : null,
        ),
        body: _currentView ?? _buildToolsList(),
      ),
    );
  }

  Widget _buildToolsList() {
    return Container(
      color: Colors.transparent,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          top: kToolbarHeight + 16,
          left: 16,
          right: 16,
          bottom: kBottomNavigationBarHeight + 16,
        ),
        child: Column(
          children: [
            _AIToolCard(
              icon: Icons.smart_toy_rounded,
              title: 'AI Assistant',
              description:
                  'Ask me anything about movies, from plot details and actors to trivia and hidden gems.',
              gradientColors: const [
                Color(0xFF2D1B69),
                Color(0xFF11998E),
              ],
              onTap: () {
                // Show interstitial ad before navigating
                final adService = AdService();
                adService.showInterstitialAd(
                  onAdClosed: () {
                    _navigateToTool(const _AssistantTab());
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            _AIToolCard(
              icon: Icons.auto_awesome_rounded,
              title: 'AI Recommender',
              description:
                  'Get personalized movie recommendations based on your current mood and preferences.',
              gradientColors: const [
                Color(0xFF8E2DE2),
                Color(0xFF4A00E0),
              ],
              onTap: () {
                // Show interstitial ad before navigating
                final adService = AdService();
                adService.showInterstitialAd(
                  onAdClosed: () {
                    _navigateToTool(const _RecommenderTab());
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            _AIToolCard(
              icon: Icons.calendar_view_day_rounded,
              title: 'AI Planner',
              description:
                  'Find the perfect movie that fits your available time and preferred genre.',
              gradientColors: const [
                Color(0xFF134E5E),
                Color(0xFF71B280),
              ],
              onTap: () {
                // Show interstitial ad before navigating
                final adService = AdService();
                adService.showInterstitialAd(
                  onAdClosed: () {
                    _navigateToTool(const _PlannerTab());
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            _AIToolCard(
              icon: Icons.quiz_rounded,
              title: 'Movie Quizzes',
              description:
                  'Test your movie knowledge with fun quizzes about films, actors, and cinema trivia.',
              gradientColors: const [
                Color(0xFF667eea),
                Color(0xFF764ba2),
              ],
              onTap: () {
                // Show interstitial ad before navigating
                final adService = AdService();
                adService.showInterstitialAd(
                  onAdClosed: () {
                    _navigateToTool(const _QuizTab());
                  },
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// AI Tool Card Widget
class _AIToolCard extends StatelessWidget {
  const _AIToolCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradientColors,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'SF Pro Display',
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Color(0xE6FFFFFF),
                      fontSize: 14,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'SF Pro Text',
                      letterSpacing: 0.3,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          offset: Offset(0, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Assistant Tab - Chat interface for movie questions
class _AssistantTab extends StatefulWidget {
  const _AssistantTab();

  @override
  State<_AssistantTab> createState() => _AssistantTabState();
}

class _AssistantTabState extends State<_AssistantTab> {
  final _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      role: _MessageRole.assistant,
      text:
          'Hi! Ask me anything about movies, from plot details and actors to trivia and hidden gems.',
    ),
  ];
  bool _isTyping = false;
  late final GenerativeModel _model;

  @override
  void initState() {
    super.initState();
    // Initialize Gemini model
    const apiKey = 'AIzaSyB43CwjitoZZ92KCqjQv5AX92M21jOfDw8';
    _model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(role: _MessageRole.user, text: text));
      _isTyping = true;
    });
    _controller.clear();

    // Auto-scroll when user sends message
    await Future.delayed(const Duration(milliseconds: 50));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

    try {
      // Call Gemini API
      final prompt =
          '''You are a movie expert assistant. Answer the following question about movies in a friendly and informative way:

Question: $text

Provide a helpful, engaging response about movies, actors, plots, trivia, or recommendations.''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      setState(() {
        _messages.add(
          _ChatMessage(
            role: _MessageRole.assistant,
            text: response.text ?? 'Sorry, I couldn\'t generate a response.',
          ),
        );
        _isTyping = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(
          _ChatMessage(
            role: _MessageRole.assistant,
            text: 'Sorry, I encountered an error: ${e.toString()}',
          ),
        );
        _isTyping = false;
      });
    }

    // Auto-scroll to bottom when new message is added
    await Future.delayed(const Duration(milliseconds: 100));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.only(
                  top: kToolbarHeight + 16,
                  left: 16,
                  right: 16,
                  bottom: kBottomNavigationBarHeight + 16,
                ),
                physics: const BouncingScrollPhysics(),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isTyping) {
                    return const _TypingIndicator();
                  }
                  return _ChatBubble(message: _messages[index]);
                },
              ),
            ),
            _ChatInput(controller: _controller, onSend: _onSend),
          ],
        ),
      ),
    );
  }
}

// Recommender Tab - Mood-based movie recommendations
class _RecommenderTab extends StatefulWidget {
  const _RecommenderTab();

  @override
  State<_RecommenderTab> createState() => _RecommenderTabState();
}

class _RecommenderTabState extends State<_RecommenderTab>
    with TickerProviderStateMixin {
  String? _selectedMood;
  String? _recommendation;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _moods = [
    {
      'name': 'Happy',
      'emoji': '😊',
      'gradient': [Color(0xFFFFD700), Color(0xFFFF8C00)],
    },
    {
      'name': 'Sad',
      'emoji': '😢',
      'gradient': [Color(0xFF4A90E2), Color(0xFF357ABD)],
    },
    {
      'name': 'Excited',
      'emoji': '🤩',
      'gradient': [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
    },
    {
      'name': 'Scared',
      'emoji': '😱',
      'gradient': [Color(0xFF6C5CE7), Color(0xFFDA0853)],
    },
    {
      'name': 'Romantic',
      'emoji': '💕',
      'gradient': [Color(0xFFFF9A9E), Color(0xFFFECAD4)],
    },
    {
      'name': 'Bored',
      'emoji': '😴',
      'gradient': [Color(0xFF74B9FF), Color(0xFF0984E3)],
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _selectMood(String mood) async {
    setState(() {
      _selectedMood = mood;
      _isLoading = true;
      _recommendation = null;
    });

    _animationController.forward();

    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 1200));

    final movieRecommendations = {
      'Happy':
          'The Grand Budapest Hotel - A whimsical and delightful comedy that will keep your spirits high! 🎭',
      'Sad':
          'Inside Out - A beautiful Pixar film that helps you understand and embrace your emotions 🌈',
      'Excited':
          'Mad Max: Fury Road - An adrenaline-pumping action masterpiece that matches your energy! 🔥',
      'Scared':
          'A Quiet Place - A thrilling horror that will give you the perfect amount of chills 👻',
      'Romantic':
          'The Princess Bride - A timeless romantic adventure that will warm your heart 💖',
      'Bored':
          'Inception - A mind-bending thriller that will completely captivate your attention 🧠',
    };

    setState(() {
      _recommendation = movieRecommendations[mood] ??
          'Great choice! Let me find the perfect movie for you.';
      _isLoading = false;
    });

    // Auto-scroll to show the recommendation
    await Future.delayed(const Duration(milliseconds: 100));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  void _clearSelection() {
    _animationController.reset();
    setState(() {
      _selectedMood = null;
      _recommendation = null;
      _isLoading = false;
    });
  }

  Future<void> _getAnotherSuggestion() async {
    if (_selectedMood == null) return;

    setState(() {
      _isLoading = true;
      _recommendation = null;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    final alternativeRecommendations = {
      'Happy': [
        'Paddington 2 - A heartwarming family film that spreads pure joy and positivity! 🐻',
        'The Grand Budapest Hotel - A whimsical and delightful comedy that will keep your spirits high! 🎭',
        'Amélie - A charming French film that celebrates life\'s simple pleasures! 🌟',
      ],
      'Sad': [
        'Inside Out - A beautiful Pixar film that helps you understand and embrace your emotions 🌈',
        'Her - A touching story about connection and healing in the digital age 💙',
        'The Pursuit of Happyness - An inspiring tale of perseverance through difficult times 🌅',
      ],
      'Excited': [
        'Mad Max: Fury Road - An adrenaline-pumping action masterpiece that matches your energy! 🔥',
        'Baby Driver - A high-octane heist film with incredible music and stunts! 🚗',
        'John Wick - Stylish action that will keep your adrenaline pumping! ⚡',
      ],
      'Scared': [
        'A Quiet Place - A thrilling horror that will give you the perfect amount of chills 👻',
        'Get Out - A brilliant psychological thriller that will keep you on edge! 😰',
        'Hereditary - A masterfully crafted horror for the brave-hearted! 🎭',
      ],
      'Romantic': [
        'The Princess Bride - A timeless romantic adventure that will warm your heart 💖',
        'Before Sunset - A beautiful conversation about love and life in Paris 🌅',
        'La La Land - A modern musical romance that will make you believe in love! 💫',
      ],
      'Bored': [
        'Inception - A mind-bending thriller that will completely captivate your attention 🧠',
        'Parasite - A gripping social thriller that will keep you engaged throughout! 🎬',
        'Knives Out - A clever whodunit that will entertain and surprise you! 🔍',
      ],
    };

    final suggestions = alternativeRecommendations[_selectedMood] ?? [];
    final randomSuggestion = suggestions.isNotEmpty
        ? suggestions[
            DateTime.now().millisecondsSinceEpoch % suggestions.length]
        : 'Here\'s another great choice for your mood!';

    setState(() {
      _recommendation = randomSuggestion;
      _isLoading = false;
    });

    // Auto-scroll to show the new recommendation
    await Future.delayed(const Duration(milliseconds: 100));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1C1B2A), Color(0xFF2A2940)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.only(
            top: kToolbarHeight + 20,
            left: 20,
            right: 20,
            bottom: kBottomNavigationBarHeight + 20,
          ),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                '✨ How are you feeling today?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose your mood and let AI find the perfect movie for you',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 32),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: _moods.length,
                itemBuilder: (context, index) {
                  final mood = _moods[index];
                  return _EnhancedMoodButton(
                    mood: mood,
                    isSelected: _selectedMood == mood['name'],
                    onTap: () => _selectMood(mood['name']),
                  );
                },
              ),
              const SizedBox(height: 40),
              if (_isLoading) ...[
                const _LoadingAnimation(),
              ] else if (_recommendation != null) ...[
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: _EnhancedSuggestionCard(text: _recommendation!),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _GlowingButton(
                        onPressed: () => _getAnotherSuggestion(),
                        text: '🎲 Another Suggestion',
                        colors: const [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _GlowingButton(
                        onPressed: _clearSelection,
                        text: '🔄 Try Another Mood',
                        colors: const [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 100), // Extra space above tab bar
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Planner Tab - Time and genre-based movie planning
class _PlannerTab extends StatefulWidget {
  const _PlannerTab();

  @override
  State<_PlannerTab> createState() => _PlannerTabState();
}

class _PlannerTabState extends State<_PlannerTab> {
  final _timeController = TextEditingController();
  String? _selectedGenre;
  String? _suggestion;
  int _suggestionCount = 0;

  @override
  void dispose() {
    _timeController.dispose();
    super.dispose();
  }

  final List<String> _genres = [
    'Action',
    'Comedy',
    'Drama',
    'Sci-Fi',
    'Horror',
    'Thriller',
    'Romance',
  ];

  final List<String> _movieTitles = [
    'The Matrix',
    'Inception',
    'Pulp Fiction',
    'The Dark Knight',
    'Forrest Gump',
    'The Godfather',
    'Interstellar',
    'Fight Club',
    'Goodfellas',
    'The Departed',
  ];

  void _findMovie() {
    // Dismiss the keyboard
    FocusScope.of(context).unfocus();

    final time = _timeController.text.trim();
    if (time.isEmpty || _selectedGenre == null) return;

    final movieTitle = _movieTitles[_suggestionCount % _movieTitles.length];
    setState(() {
      _suggestion =
          'Here\'s a great $_selectedGenre movie that\'s about $time minutes long: $movieTitle.';
      _suggestionCount++;
    });
  }

  void _anotherSuggestion() {
    final time = _timeController.text.trim();
    if (time.isEmpty || _selectedGenre == null) return;

    final movieTitle = _movieTitles[_suggestionCount % _movieTitles.length];
    setState(() {
      _suggestion =
          'Here\'s a great $_selectedGenre movie that\'s about $time minutes long: $movieTitle.';
      _suggestionCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1C1B2A),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            top: kToolbarHeight + 16,
            left: 16,
            right: 16,
            bottom: kBottomNavigationBarHeight + 16,
          ),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How much time do you have?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _timeController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Time in minutes (e.g., 90)',
                  hintStyle: const TextStyle(color: Colors.white60),
                  filled: true,
                  fillColor: const Color(0xFF3A395B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'What genre are you in the mood for?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedGenre,
                onChanged: (value) => setState(() => _selectedGenre = value),
                style: const TextStyle(color: Colors.white),
                dropdownColor: const Color(0xFF3A395B),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF3A395B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _genres
                    .map(
                      (genre) => DropdownMenuItem(
                        value: genre,
                        child: Text(
                          genre,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: _findMovie,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A395B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'Find Me a Movie',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              if (_suggestion != null) ...[
                const SizedBox(height: 24),
                _SuggestionCard(text: _suggestion!),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: _anotherSuggestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3A395B),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Another Suggestion'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Shared UI Components
class _ChatInput extends StatelessWidget {
  const _ChatInput({required this.controller, required this.onSend});
  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF3A395B),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Ask me anything…',
                  hintStyle: TextStyle(color: Colors.white60),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
            IconButton(
              onPressed: onSend,
              icon: const Icon(Icons.send_rounded, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

enum _MessageRole { user, assistant }

class _ChatMessage {
  const _ChatMessage({required this.role, required this.text});
  final _MessageRole role;
  final String text;
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});
  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == _MessageRole.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF3A395B) : const Color(0xFF2A2940),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.text,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Text(
          'typing...',
          style: TextStyle(color: Colors.white60, fontStyle: FontStyle.italic),
        ),
      ),
    );
  }
}

// Enhanced Mood Button with Emojis and Gradients
class _EnhancedMoodButton extends StatefulWidget {
  const _EnhancedMoodButton({
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  final Map<String, dynamic> mood;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_EnhancedMoodButton> createState() => _EnhancedMoodButtonState();
}

class _EnhancedMoodButtonState extends State<_EnhancedMoodButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: 120, // Fixed height to prevent layout issues
              decoration: BoxDecoration(
                gradient: widget.isSelected
                    ? LinearGradient(
                        colors: widget.mood['gradient'],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [
                          const Color(0xFF3A395B).withValues(alpha: 0.8),
                          const Color(0xFF2A2940).withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.isSelected
                      ? Colors.white.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.1),
                  width: 2,
                ),
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: widget.mood['gradient'][0].withValues(
                            alpha: 0.4,
                          ),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.mood['emoji'],
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.mood['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Loading Animation Widget
class _LoadingAnimation extends StatefulWidget {
  const _LoadingAnimation();

  @override
  State<_LoadingAnimation> createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<_LoadingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _animation.value * 2 * 3.14159,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const Text(
            '🎬 Finding your perfect movie...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Enhanced Suggestion Card
class _EnhancedSuggestionCard extends StatelessWidget {
  const _EnhancedSuggestionCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.movie_outlined, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'Perfect Match!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// Glowing Button
class _GlowingButton extends StatelessWidget {
  const _GlowingButton({
    required this.onPressed,
    required this.text,
    this.colors = const [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
  });
  final VoidCallback onPressed;
  final String text;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF3A395B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
      ),
    );
  }
}

// Quiz Tab - Movie and Actor Quizzes
class _QuizTab extends StatefulWidget {
  const _QuizTab();

  @override
  State<_QuizTab> createState() => _QuizTabState();
}

class _QuizTabState extends State<_QuizTab> with TickerProviderStateMixin {
  int _currentQuizIndex = 0;
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isQuizCompleted = false;
  bool _isAnswerSelected = false;
  int? _selectedAnswerIndex;
  bool _showCorrectAnswer = false;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  final List<Map<String, dynamic>> _quizzes = [
    {
      'title': '🎬 Classic Movies',
      'icon': Icons.movie_creation_rounded,
      'gradient': [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
      'questions': [
        {
          'question':
              'Which movie features the famous line "Here\'s looking at you, kid"?',
          'options': [
            'Gone with the Wind',
            'Casablanca',
            'Citizen Kane',
            'The Maltese Falcon',
          ],
          'correctAnswer': 1,
        },
        {
          'question': 'Who directed the movie "Psycho" (1960)?',
          'options': [
            'Stanley Kubrick',
            'Alfred Hitchcock',
            'Orson Welles',
            'Billy Wilder',
          ],
          'correctAnswer': 1,
        },
        {
          'question':
              'In "The Godfather", what does Al Pacino\'s character find on his pillow?',
          'options': ['A gun', 'A rose', 'A horse head', 'A letter'],
          'correctAnswer': 2,
        },
      ],
    },
    {
      'title': '🌟 Hollywood Stars',
      'icon': Icons.star_rounded,
      'gradient': [Color(0xFF4ECDC4), Color(0xFF44A08D)],
      'questions': [
        {
          'question': 'Which actor played the Joker in "The Dark Knight"?',
          'options': [
            'Joaquin Phoenix',
            'Jack Nicholson',
            'Heath Ledger',
            'Jared Leto',
          ],
          'correctAnswer': 2,
        },
        {
          'question':
              'Who won the Academy Award for Best Actor for "Forrest Gump"?',
          'options': [
            'Tom Hanks',
            'Robin Williams',
            'Kevin Costner',
            'Denzel Washington',
          ],
          'correctAnswer': 0,
        },
        {
          'question': 'Which actress starred in "Black Swan"?',
          'options': [
            'Anne Hathaway',
            'Natalie Portman',
            'Emma Stone',
            'Scarlett Johansson',
          ],
          'correctAnswer': 1,
        },
      ],
    },
    {
      'title': '🎭 Movie Trivia',
      'icon': Icons.theater_comedy_rounded,
      'gradient': [Color(0xFF667eea), Color(0xFF764ba2)],
      'questions': [
        {
          'question':
              'What is the highest-grossing film of all time (as of 2023)?',
          'options': [
            'Titanic',
            'Avatar',
            'Avengers: Endgame',
            'Star Wars: The Force Awakens',
          ],
          'correctAnswer': 1,
        },
        {
          'question':
              'Which movie won the first-ever Academy Award for Best Picture?',
          'options': ['Wings', 'Sunrise', 'The Jazz Singer', 'Metropolis'],
          'correctAnswer': 0,
        },
        {
          'question':
              'How many "Lord of the Rings" movies did Peter Jackson direct?',
          'options': ['2', '3', '4', '6'],
          'correctAnswer': 1,
        },
      ],
    },
    {
      'title': '🎥 Directors & Filmmaking',
      'icon': Icons.videocam_rounded,
      'gradient': [Color(0xFFf093fb), Color(0xFFf5576c)],
      'questions': [
        {
          'question': 'Who directed "Pulp Fiction"?',
          'options': [
            'Martin Scorsese',
            'Quentin Tarantino',
            'Christopher Nolan',
            'David Fincher',
          ],
          'correctAnswer': 1,
        },
        {
          'question': 'Which director is known for the "Dark Knight" trilogy?',
          'options': [
            'Zack Snyder',
            'Christopher Nolan',
            'Tim Burton',
            'Sam Raimi',
          ],
          'correctAnswer': 1,
        },
        {
          'question': 'Who directed "Jaws"?',
          'options': [
            'George Lucas',
            'Steven Spielberg',
            'Francis Ford Coppola',
            'Brian De Palma',
          ],
          'correctAnswer': 1,
        },
      ],
    },
    {
      'title': '🏆 Awards & Recognition',
      'icon': Icons.emoji_events_rounded,
      'gradient': [Color(0xFFFFD700), Color(0xFFFF8C00)],
      'questions': [
        {
          'question':
              'Which movie won the Academy Award for Best Picture in 2020?',
          'options': [
            '1917',
            'Joker',
            'Parasite',
            'Once Upon a Time in Hollywood',
          ],
          'correctAnswer': 2,
        },
        {
          'question': 'Who has won the most Academy Awards for acting?',
          'options': [
            'Meryl Streep',
            'Katharine Hepburn',
            'Jack Nicholson',
            'Daniel Day-Lewis',
          ],
          'correctAnswer': 1,
        },
        {
          'question':
              'Which film won both Best Picture and Best Animated Feature in the same year?',
          'options': [
            'Up',
            'Toy Story 3',
            'Inside Out',
            'None - different categories',
          ],
          'correctAnswer': 3,
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _selectQuiz(int index) {
    setState(() {
      _currentQuizIndex = index;
      _currentQuestionIndex = 0;
      _score = 0;
      _isQuizCompleted = false;
      _isAnswerSelected = false;
      _selectedAnswerIndex = null;
      _showCorrectAnswer = false;
    });
    _slideController.forward();
  }

  void _selectAnswer(int answerIndex) async {
    if (_isAnswerSelected) return;

    setState(() {
      _isAnswerSelected = true;
      _selectedAnswerIndex = answerIndex;
    });

    _scaleController.forward().then((_) => _scaleController.reverse());

    await Future.delayed(const Duration(milliseconds: 500));

    final currentQuiz = _quizzes[_currentQuizIndex];
    final currentQuestion = currentQuiz['questions'][_currentQuestionIndex];
    final isCorrect = answerIndex == currentQuestion['correctAnswer'];

    if (isCorrect) {
      setState(() {
        _score++;
      });
    }

    setState(() {
      _showCorrectAnswer = true;
    });

    await Future.delayed(const Duration(milliseconds: 1500));

    if (_currentQuestionIndex < currentQuiz['questions'].length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isAnswerSelected = false;
        _selectedAnswerIndex = null;
        _showCorrectAnswer = false;
      });
    } else {
      setState(() {
        _isQuizCompleted = true;
      });
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _isQuizCompleted = false;
      _isAnswerSelected = false;
      _selectedAnswerIndex = null;
      _showCorrectAnswer = false;
    });
  }

  void _goBackToQuizList() {
    _slideController.reverse();
  }

  String _getScoreMessage() {
    final totalQuestions = _quizzes[_currentQuizIndex]['questions'].length;
    final percentage = (_score / totalQuestions * 100).round();

    if (percentage >= 90) return '🏆 Outstanding! You\'re a movie expert!';
    if (percentage >= 70) return '🌟 Great job! You know your movies!';
    if (percentage >= 50) return '👍 Not bad! Keep watching more films!';
    return '🎬 Time to binge some classics!';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1C1B2A), Color(0xFF2A2940)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: AnimatedBuilder(
        animation: _slideController,
        builder: (context, child) {
          return _slideController.value == 0
              ? _buildQuizList()
              : SlideTransition(
                  position: _slideAnimation,
                  child: _buildQuizInterface(),
                );
        },
      ),
    );
  }

  Widget _buildQuizList() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: kToolbarHeight + 20,
          left: 20,
          right: 20,
          bottom: kBottomNavigationBarHeight + 20,
        ),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🎯 Choose Your Quiz',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Test your movie knowledge with these fun quizzes',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 32),
            ...List.generate(_quizzes.length, (index) {
              final quiz = _quizzes[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _QuizCard(
                  title: quiz['title'],
                  icon: quiz['icon'],
                  gradientColors: quiz['gradient'],
                  questionCount: quiz['questions'].length,
                  onTap: () => _selectQuiz(index),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizInterface() {
    if (_isQuizCompleted) {
      return _buildQuizResults();
    }

    final currentQuiz = _quizzes[_currentQuizIndex];
    final currentQuestion = currentQuiz['questions'][_currentQuestionIndex];
    final progress =
        (_currentQuestionIndex + 1) / currentQuiz['questions'].length;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: kToolbarHeight + 20,
          left: 20,
          right: 20,
          bottom: kBottomNavigationBarHeight + 20,
        ),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: _goBackToQuizList,
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                Expanded(
                  child: Text(
                    currentQuiz['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Progress Bar
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: currentQuiz['gradient']),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Question ${_currentQuestionIndex + 1} of ${currentQuiz['questions'].length}',
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),

            // Question
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: currentQuiz['gradient']),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: currentQuiz['gradient'][0].withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Text(
                currentQuestion['question'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),

            // Answer Options
            ...List.generate(currentQuestion['options'].length, (index) {
              final isSelected = _selectedAnswerIndex == index;
              final isCorrect = index == currentQuestion['correctAnswer'];
              final showResult = _showCorrectAnswer;

              Color? backgroundColor;
              if (showResult) {
                if (isCorrect) {
                  backgroundColor = Colors.green.withValues(alpha: 0.3);
                } else if (isSelected && !isCorrect) {
                  backgroundColor = Colors.red.withValues(alpha: 0.3);
                }
              } else if (isSelected) {
                backgroundColor = currentQuiz['gradient'][0].withValues(
                  alpha: 0.3,
                );
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: isSelected ? _scaleAnimation.value : 1.0,
                      child: GestureDetector(
                        onTap: () => _selectAnswer(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: backgroundColor ?? const Color(0xFF3A395B),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: showResult && isCorrect
                                  ? Colors.green
                                  : showResult && isSelected && !isCorrect
                                      ? Colors.red
                                      : isSelected
                                          ? currentQuiz['gradient'][0]
                                          : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(
                                      65 + index,
                                    ), // A, B, C, D
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  currentQuestion['options'][index],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (showResult && isCorrect)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 24,
                                ),
                              if (showResult && isSelected && !isCorrect)
                                const Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizResults() {
    final currentQuiz = _quizzes[_currentQuizIndex];
    final totalQuestions = currentQuiz['questions'].length;
    final percentage = (_score / totalQuestions * 100).round();

    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(
            top: kToolbarHeight + 40,
            left: 20,
            right: 20,
            bottom: kBottomNavigationBarHeight + 20,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: currentQuiz['gradient']),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: currentQuiz['gradient'][0].withValues(alpha: 0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(currentQuiz['icon'], color: Colors.white, size: 64),
                    const SizedBox(height: 20),
                    const Text(
                      'Quiz Complete!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your Score: $_score/$totalQuestions ($percentage%)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getScoreMessage(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: _GlowingButton(
                      onPressed: _restartQuiz,
                      text: '🔄 Try Again',
                      colors: currentQuiz['gradient'],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _GlowingButton(
                      onPressed: _goBackToQuizList,
                      text: '📚 More Quizzes',
                      colors: const [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Quiz Card Widget
class _QuizCard extends StatefulWidget {
  const _QuizCard({
    required this.title,
    required this.icon,
    required this.gradientColors,
    required this.questionCount,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final List<Color> gradientColors;
  final int questionCount;
  final VoidCallback onTap;

  @override
  State<_QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<_QuizCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: widget.gradientColors.first.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(widget.icon, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${widget.questionCount} questions • Test your knowledge',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

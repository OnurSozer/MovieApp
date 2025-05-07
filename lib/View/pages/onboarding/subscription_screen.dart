import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../ViewModel/stores/user_store.dart';
import '../../widgets/custom_button.dart';
import '../main_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> with TickerProviderStateMixin {
  // Constants for layout calculations
  static const double _headerHeight = 24.0;
  static const double _featureRowHeight = 48.0;
  static const int _watchlistIndex = 2; // 0-based index for Personalized Watchlists
  static const int _adFreeIndex = 3; // 0-based index for Ad-Free Experience

  late UserStore _userStore;
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;
  late AnimationController _switchButtonController;
  late Animation<double> _switchButtonAnimation;
  late AnimationController _markPositionController;
  late Animation<double> _markPositionAnimation;
  
  String _selectedPlan = 'weekly'; // 'weekly', 'monthly', 'yearly'
  bool _enableFreeTrial = false;

  @override
  void initState() {
    super.initState();
    
    // Get store from dependency injection
    _userStore = GetIt.instance<UserStore>();
    
    // Initialize fade animation
    _fadeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeIn,
      ),
    );
    
    // Initialize pulse animation
    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Initialize switch button animation
    _switchButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..forward(); // Start at fully visible
    
    _switchButtonAnimation = CurvedAnimation(
      parent: _switchButtonController,
      curve: Curves.easeInOut,
    );

    // Initialize mark position animation - position 0.0 is top (watchlist), 1.0 is bottom (ad-free)
    _markPositionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      value: 0.0, // Start with the mark at the top position (watchlist)
    );
    
    _markPositionAnimation = CurvedAnimation(
      parent: _markPositionController,
      curve: Curves.easeInOut,
    );
    
    // Start fade animation
    _fadeAnimationController.forward();
  }
  
  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _pulseAnimationController.dispose();
    _switchButtonController.dispose();
    _markPositionController.dispose();
    super.dispose();
  }
  
  void _completeOnboarding() async {
    // Mark onboarding as completed
    await _userStore.completeOnboarding();
    
    // Set subscription status based on selection
    await _userStore.updateSubscription(_selectedPlan == 'free' ? 'free' : 'premium');
    
    // Ensure animations are reset
    _markPositionController.value = _selectedPlan == 'monthly' ? 1.0 : 0.0;
    
    // Navigate to main screen
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainScreen()),
      (route) => false,
    );
  }
  
  void _skipSubscription() async {
    // Mark onboarding as completed with free plan
    await _userStore.completeOnboarding();
    await _userStore.updateSubscription('free');
    
    // Ensure animations are reset
    _markPositionController.value = 0.0;
    
    // Navigate to main screen
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainScreen()),
      (route) => false,
    );
  }

  // Calculate position for feature at given index
  double _getFeaturePosition(int index) {
    return _headerHeight + (index * _featureRowHeight);
  }

  // Helper function to determine if feature is included based on selected plan
  bool isFeatureIncluded(String feature) {
    switch (feature) {
      case 'Daily Movie Suggestions':
        return _selectedPlan != 'free'; // Available in all paid plans
      case 'AI-Powered Movie Insights':
        return _selectedPlan != 'free'; // Available in all paid plans
      case 'Personalized Watchlists':
        return _selectedPlan == 'monthly' || _selectedPlan == 'yearly'; // Only in monthly and yearly
      case 'Ad-Free Experience':
        return _selectedPlan == 'yearly'; // Only in yearly plan
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Custom Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: const Text(
                    'MovieHub',
                    style: AppTextStyles.heading1,
                    textAlign: TextAlign.center,
                  ),
                ),
                // Main Content
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            // Comparison Tabler
                            _buildComparisonTable(),
                            
                            const SizedBox(height: 24),
                            
                            // Free Trial Toggle
                            _buildFreeTrialToggle(),
                            
                            const SizedBox(height: 24),
                            
                            // Subscription Plans
                            _buildSubscriptionPlans(),
                            
                            const SizedBox(height: 8),
                            
                            // Subscribe Button
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform(
                                  transform: Matrix4.identity()
                                    ..scale(
                                      _enableFreeTrial ? _pulseAnimation.value : 1.0,
                                      1.0,
                                      1.0,
                                    ),
                                  alignment: Alignment.center,
                                  child: AnimatedBuilder(
                                    animation: _switchButtonAnimation,
                                    builder: (context, child) {
                                      return Opacity(
                                        opacity: _switchButtonController.value,
                                        child: PrimaryButton(
                                          text: _enableFreeTrial
                                              ? '3 Days Free\nNo Payment Now'
                                              : 'Unlock MovieHub PRO',
                                          onPressed: _completeOnboarding,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                            
                            // Terms and Conditions
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    // Handle Terms of Use
                                  },
                                  child: Text(
                                    'Terms of Use',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.grey,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Handle Restore Purchase
                                  },
                                  child: Text(
                                    'Restore Purchase',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.grey,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Handle Privacy Policy
                                  },
                                  child: Text(
                                    'Privacy Policy',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.grey,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Close button positioned absolutely
            Positioned(
              top: -15,
              right: 0,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: _skipSubscription,
                icon: const Icon(
                  Icons.close,
                  color: AppColors.grey,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildComparisonTable() {
    return Row(
      children: [
        // Features and FREE column
        Expanded(
          flex: 4,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
                  child: Row(
                    children: [
                      const Expanded(flex: 3, child: SizedBox()),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'FREE',
                          style: AppTextStyles.heading3,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Features with FREE column
                _buildFeatureRowWithoutPro(
                  'Daily Movie Suggestions',
                  true,
                ),
                _buildFeatureRowWithoutPro(
                  'AI-Powered Movie Insights',
                  false,
                ),
                _buildFeatureRowWithoutPro(
                  'Personalized Watchlists',
                  false,
                ),
                _buildFeatureRowWithoutPro(
                  'Ad-Free Experience',
                  false,
                ),
              ],
            ),
          ),
        ),
        
        // PRO column with red border
        Container(
          width: 60,
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.redLight, width: 1),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  // PRO Header
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 9.0),
                    child: Text(
                      'PRO',
                      style: AppTextStyles.heading3,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  // PRO checkmarks based on selected plan
                  _buildProCheckmark(isFeatureIncluded('Daily Movie Suggestions')),
                  _buildProCheckmark(isFeatureIncluded('AI-Powered Movie Insights')),
                  _buildProCheckmark(isFeatureIncluded('Personalized Watchlists')),
                  _buildProCheckmark(isFeatureIncluded('Ad-Free Experience')),
                ],
              ),
              _buildAnimatedMarks(),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildFeatureRowWithoutPro(String feature, bool isFreeIncluded) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              feature,
              style: AppTextStyles.bodyMedium,
            ),
          ),
          Expanded(
            flex: 1,
            child: Icon(
              isFreeIncluded ? Icons.check_circle : Icons.cancel,
              color: isFreeIncluded ? Colors.green : AppColors.grey,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProCheckmark(bool isIncluded) {
    // For yearly plan, all features are included
    final bool showCheckmark = isIncluded || _selectedPlan == 'yearly';
    
    // Only hide static icons for the specific positions that will have animated marks
    // For monthly plan, Personalized Watchlists are included
    final bool isWatchlistRow = _featureRowHeight * _watchlistIndex == _getFeaturePosition(_watchlistIndex);
    final bool isAdFreeRow = _featureRowHeight * _adFreeIndex == _getFeaturePosition(_adFreeIndex);
    
    // Skip rendering for positions that will be shown by the animated mark
    if (_selectedPlan == 'weekly' && isWatchlistRow && !isIncluded) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: const SizedBox(width: 24, height: 24), // Placeholder of the same size
      );
    }
    
    // Skip rendering for ad-free row which always has a crossmark when not yearly
    if (_selectedPlan != 'yearly' && isAdFreeRow && !isIncluded) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: const SizedBox(width: 24, height: 24), // Placeholder of the same size
      );
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Icon(
        showCheckmark ? Icons.check_circle : Icons.cancel,
        color: showCheckmark ? Colors.green : AppColors.grey,
        size: 24,
      ),
    );
  }

  Widget _buildAnimatedMarks() {
    return AnimatedBuilder(
      animation: _markPositionAnimation,
      builder: (context, child) {
        // Do not show marks for yearly plan
        if (_selectedPlan == 'yearly') {
          return const SizedBox.shrink();
        }
        
        // Calculate positions
        final watchlistPosition = _getFeaturePosition(_watchlistIndex);
        final adFreePosition = _getFeaturePosition(_adFreeIndex);
        
        // Interpolate position for animated mark
        final double topPosition = watchlistPosition + 
            (adFreePosition - watchlistPosition) * _markPositionAnimation.value;
        
        // For monthly plan, Personalized Watchlists are included (no crossmark)
        // Only Ad-Free should have a crossmark
        final bool showAnimatedMark = _selectedPlan == 'weekly' || 
                                     (_selectedPlan == 'monthly' && _markPositionAnimation.value > 0.5);
        
        // Using a Container with specific dimensions to fix the layout issue
        return SizedBox(
          width: double.infinity,
          height: adFreePosition + 60, // Make sure it's tall enough to contain both positions
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Only show animated mark when appropriate
              if (showAnimatedMark)
                Positioned(
                  top: topPosition + 26,
                  left: 0,
                  right: 0,
                  child: const Icon(
                    Icons.cancel,
                    color: AppColors.grey,
                    size: 24,
                  ),
                ),
              
              // For weekly plan, always show a mark at ad-free position when not being animated
              if (_selectedPlan == 'weekly' && _markPositionAnimation.value < 0.05)
                Positioned(
                  top: adFreePosition + 26,
                  left: 0,
                  right: 0,
                  child: const Icon(
                    Icons.cancel,
                    color: AppColors.grey,
                    size: 24,
                  ),
                ),
              
              // Monthly plan - only show crossmark for Ad-Free Experience, not for Watchlists
              if (_selectedPlan == 'monthly')
                Positioned(
                  top: adFreePosition + 26, // Position at ad-free row
                  left: 0,
                  right: 0,
                  child: const Icon(
                    Icons.cancel,
                    color: AppColors.grey,
                    size: 24,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildSubscriptionPlans() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Weekly Plan
        _buildPlanOption(
          'weekly',
          'Weekly',
          '\$4,99',
          'Only \$4,99 per week',
        ),
        
        const SizedBox(height: 18),
        
        // Monthly Plan
        _buildPlanOption(
          'monthly',
          'Monthly',
          '\$11,99',
          'Only \$2,99 per week',
        ),
        
        const SizedBox(height: 18),
        
        // Yearly Plan
        _buildPlanOption(
          'yearly',
          'Yearly',
          '\$49,99',
          'Only \$0,96 per week',
          isPopular: true,
        ),

        const SizedBox(height: 14),
        
        // Auto-renewal info
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.security,
              color: Colors.green,
              size: 18,
            ),
            const SizedBox(width: 4),
            Text(
              'Auto Renewable, Cancel Anytime',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.grey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildPlanOption(String planId, String title, String price, String subtitle, {bool isPopular = false}) {
    final isSelected = _selectedPlan == planId;
    final period = planId == 'weekly' ? ' / week' : planId == 'monthly' ? ' / month' : ' / year';
    
    return GestureDetector(
      onTap: () {
        if (_selectedPlan != planId) {
          // Track previous plan to handle animation
          final String previousPlan = _selectedPlan;
          
          // If enabling yearly plan, disable free trial toggle if it was on
          if (planId == 'yearly' && _enableFreeTrial) {
            setState(() {
              _enableFreeTrial = false;
            });
          }
          
          setState(() {
            _selectedPlan = planId;
          });
          
          // Handle animated mark position
          if (planId == 'monthly' && (previousPlan == 'weekly' || previousPlan == 'yearly')) {
            // Moving to monthly - animate mark to bottom position
            _markPositionController.animateTo(1.0);
          } 
          else if (planId == 'weekly' && (previousPlan == 'monthly' || previousPlan == 'yearly')) {
            // Moving to weekly - animate mark to top position
            _markPositionController.animateTo(0.0);
          }
          // When moving to yearly, the mark disappears (handled in _buildAnimatedMarks)
        }
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.redLight : AppColors.greyDark,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 18),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.redLight : AppColors.greyDark,
                      width: 2,
                    ),
                    color: isSelected ? AppColors.redLight : Colors.transparent,
                  ),
                  child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 14,
                      )
                    : null,
                ),
                
                const SizedBox(width: 18),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.heading3,
                      ),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.greyDark),
                      ),
                    ],
                  ),
                ),
                
                Text(
                  '$price$period',
                  style: AppTextStyles.heading3.copyWith(color: AppColors.white),
                ),

                const SizedBox(width: 12),
              ],
            ),
          ),
          if (isPopular)
            Positioned(
              top: -12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.redLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Best Value',
                    style: AppTextStyles.heading3.copyWith(fontSize: 12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildFreeTrialToggle() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.redLight, width: 1),
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              'Enable Free Trial',
              style: AppTextStyles.heading3,
            ),
          ),
          const SizedBox(width: 10),
          Switch(
            value: _enableFreeTrial,
            onChanged: (value) async {
              if (value) {
                // Turning ON free trial, going to yearly plan
                setState(() {
                  _enableFreeTrial = value;
                  _selectedPlan = 'yearly';
                });
                _pulseAnimationController.repeat(reverse: true);
              } else {
                // Turning OFF free trial
                await _switchButtonController.reverse();
                
                final String previousPlan = _selectedPlan; // Should be 'yearly'
                
                setState(() {
                  _enableFreeTrial = value;
                  _selectedPlan = 'weekly'; // Default back to weekly
                });
                
                // Reset animation and then animate to proper position
                // When going from yearly to weekly, mark should be at the top
                _markPositionController.value = 0.0;
                
                _pulseAnimationController.stop();
                _pulseAnimationController.reset();
                await _switchButtonController.forward();
              }
            },
            activeColor: Colors.white,
            activeTrackColor: Colors.green,
            inactiveTrackColor: Colors.grey.shade900,
            inactiveThumbColor: Colors.white,
            trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
            thumbIcon: MaterialStateProperty.all(
              const Icon(Icons.circle, color: Colors.white, size: 36),
            ),
          ),
          const SizedBox(width: 15),
        ],
      ),
    );
  }
} 
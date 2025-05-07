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
  late UserStore _userStore;
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;
  late AnimationController _switchButtonController;
  late Animation<double> _switchButtonAnimation;
  
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
    
    // Start fade animation
    _fadeAnimationController.forward();
  }
  
  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _pulseAnimationController.dispose();
    _switchButtonController.dispose();
    super.dispose();
  }
  
  void _completeOnboarding() async {
    // Mark onboarding as completed
    await _userStore.completeOnboarding();
    
    // Set subscription status based on selection
    await _userStore.updateSubscription(_selectedPlan == 'free' ? 'free' : 'premium');
    
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
    
    // Navigate to main screen
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainScreen()),
      (route) => false,
    );
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
          child: Column(
            children: [
              // PRO Header
              Padding(
                padding: const EdgeInsets.all(6.0),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Icon(
        isIncluded ? Icons.check_circle : Icons.cancel,
        color: isIncluded ? Colors.green : AppColors.grey,
        size: 24,
      ),
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
        setState(() {
          _selectedPlan = planId;
        });
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
                // Turning ON free trial
                setState(() {
                  _enableFreeTrial = value;
                  _selectedPlan = 'yearly';
                });
                _pulseAnimationController.repeat(reverse: true);
              } else {
                // Turning OFF free trial
                await _switchButtonController.reverse();
                setState(() {
                  _enableFreeTrial = value;
                });
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
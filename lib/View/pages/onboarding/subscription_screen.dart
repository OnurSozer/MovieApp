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

class _SubscriptionScreenState extends State<SubscriptionScreen> with SingleTickerProviderStateMixin {
  late UserStore _userStore;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  String _selectedPlan = 'weekly'; // 'weekly', 'monthly', 'yearly'
  bool _enableFreeTrial = true;

  @override
  void initState() {
    super.initState();
    
    // Get store from dependency injection
    _userStore = GetIt.instance<UserStore>();
    
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    
    // Start animation
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
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
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: const Text(
                    'MovieHub',
                    style: AppTextStyles.heading3,
                    textAlign: TextAlign.center,
                  ),
                ),
                // Main Content
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            // Comparison Table
                            _buildComparisonTable(),
                            
                            const SizedBox(height: 24),
                            
                            // Free Trial Toggle
                            _buildFreeTrialToggle(),
                            
                            const SizedBox(height: 24),
                            
                            // Subscription Plans
                            _buildSubscriptionPlans(),
                            
                            const SizedBox(height: 24),
                            
                            // Subscribe Button
                            PrimaryButton(
                              text: _selectedPlan == 'free' 
                                  ? 'Continue with Free Plan' 
                                  : 'Unlock MovieHub PRO',
                              onPressed: _completeOnboarding,
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Terms and Conditions
                            Center(
                              child: Text(
                                'By continuing, you agree to our Terms & Conditions\nand Privacy Policy',
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey),
                                textAlign: TextAlign.center,
                              ),
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
              top: 4,
              right: 4,
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Row(
              children: [
                const Expanded(flex: 3, child: SizedBox()),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Text(
                        'FREE',
                        style: AppTextStyles.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Text(
                        'PRO',
                        style: AppTextStyles.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Features
          _buildFeatureRow(
            'Daily Movie Suggestions',
            true, 
            true,
          ),
          _buildFeatureRow(
            'AI-Powered Movie Insights',
            false, 
            true,
          ),
          _buildFeatureRow(
            'Personalized Watchlists',
            false, 
            true,
          ),
          _buildFeatureRow(
            'Ad-Free Experience',
            false, 
            true,
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeatureRow(String feature, bool isFreeIncluded, bool isProIncluded) {
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
              size: 20,
            ),
          ),
          Expanded(
            flex: 1,
            child: Icon(
              isProIncluded ? Icons.check_circle : Icons.cancel,
              color: isProIncluded ? Colors.green : AppColors.grey,
              size: 20,
            ),
          ),
        ],
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
          '\$4.99',
          'Only \$4.99 per week',
        ),
        
        const SizedBox(height: 16),
        
        // Monthly Plan
        _buildPlanOption(
          'monthly',
          'Monthly',
          '\$11.99',
          'Only \$2.99 per week',
          isPopular: true,
        ),
        
        const SizedBox(height: 16),
        
        // Yearly Plan
        _buildPlanOption(
          'yearly',
          'Yearly',
          '\$49.99',
          'Only \$0.96 per week',
        ),

        const SizedBox(height: 16),
        
        // Auto-renewal info
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 14,
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
      child: Container(
        padding: const EdgeInsets.all(16),
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
            // Radio Button
            Radio(
              value: planId,
              groupValue: _selectedPlan,
              onChanged: (value) {
                setState(() {
                  _selectedPlan = value as String;
                });
              },
              activeColor: AppColors.redLight,
            ),
            const SizedBox(width: 0),
            
            // Plan Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.bodyLarge,
                      ),
                      if (isPopular) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.redLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'BEST VALUE',
                            style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                          ),
                        ),
                      ]
                    ],
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey),
                  ),
                ],
              ),
            ),
            
            // Price
            Text(
              '$price$period',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
            ),
          ],
        ),
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
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Enable Free Trial',
              style: AppTextStyles.bodyLarge,
            ),
          ),
          const SizedBox(width: 10),
          Switch(
            value: _enableFreeTrial,
            onChanged: (value) {
              setState(() {
                _enableFreeTrial = value;
              });
            },
            activeColor: Colors.white,
            activeTrackColor: Colors.green,
            inactiveTrackColor: Colors.grey.shade900,
            inactiveThumbColor: Colors.white,
            trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
            thumbIcon: MaterialStateProperty.all(
              const Icon(Icons.circle, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
} 
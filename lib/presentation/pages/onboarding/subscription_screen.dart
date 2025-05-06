import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../stores/user_store.dart';
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
  
  String _selectedPlan = 'monthly'; // 'weekly', 'monthly', 'yearly'
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'MovieHub',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.redLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'PRO',
                style: AppTextStyles.bodySmall,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _skipSubscription,
            child: Text(
              'Skip',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
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
                  
                  // Subscription Plans
                  _buildSubscriptionPlans(),
                  
                  const SizedBox(height: 16),
                  
                  // Free Trial Toggle
                  _buildFreeTrialToggle(),
                  
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
    );
  }
  
  Widget _buildComparisonTable() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.greyDark, width: 1),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
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
            'Personalized Watchlists',
            false, 
            true,
          ),
          _buildFeatureRow(
            'AI-Powered Movie Insights',
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
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.greyDark, width: 1),
        ),
      ),
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
          'week',
          'Billed weekly',
        ),
        
        const SizedBox(height: 16),
        
        // Monthly Plan
        _buildPlanOption(
          'monthly',
          'Monthly',
          '\$11.99',
          'month',
          'Save \$8 per month',
          isPopular: true,
        ),
        
        const SizedBox(height: 16),
        
        // Yearly Plan
        _buildPlanOption(
          'yearly',
          'Yearly',
          '\$49.99',
          'year',
          'Best value! Save 65%',
        ),
        
        const SizedBox(height: 16),
        
        // Free Plan
        _buildPlanOption(
          'free',
          'Free',
          '\$0.00',
          'forever',
          'Limited features',
        ),
      ],
    );
  }
  
  Widget _buildPlanOption(String planId, String title, String price, String period, String subtitle, {bool isPopular = false}) {
    final isSelected = _selectedPlan == planId;
    
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
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.redLight : AppColors.greyDark,
            width: isSelected ? 2 : 1,
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
            const SizedBox(width: 8),
            
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: AppTextStyles.priceText,
                ),
                Text(
                  '/ $period',
                  style: AppTextStyles.pricePeriodText,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFreeTrialToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.greyDark, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enable Free Trial',
                  style: AppTextStyles.bodyLarge,
                ),
                Text(
                  'Try PRO features for 7 days',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey),
                ),
              ],
            ),
          ),
          Switch(
            value: _enableFreeTrial,
            onChanged: _selectedPlan == 'free' 
                ? null 
                : (value) {
                    setState(() {
                      _enableFreeTrial = value;
                    });
                  },
            activeColor: AppColors.redLight,
          ),
        ],
      ),
    );
  }
} 
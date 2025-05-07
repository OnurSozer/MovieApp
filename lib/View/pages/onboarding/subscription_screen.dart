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
    // Helper function to determine if feature is included based on selected plan
    bool isFeatureIncluded(String feature) {
      switch (feature) {
        case 'Daily Movie Suggestions':
          return true; // Available in all plans
        case 'AI-Powered Movie Insights':
          return _selectedPlan == 'yearly'; // Only in yearly
        case 'Personalized Watchlists':
          return _selectedPlan == 'yearly' || _selectedPlan == 'monthly'; // In yearly and monthly
        case 'Ad-Free Experience':
          return _selectedPlan != 'free'; // In all paid plans
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
          width: 80,
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
              const Icon(Icons.circle, color: Colors.white, size: 36),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
} 
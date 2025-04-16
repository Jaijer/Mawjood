import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mawjood/screens/home_screen.dart';

import '../../components/theme.dart';

import '../landing_page/profilestep.dart';

import '../../components/button.dart';
import '../../components/spaces.dart';
import '../../components/textfield.dart';

import 'ax_step.dart';

class AxOnboardingFlow extends HookWidget {
  const AxOnboardingFlow({super.key});

  // Future<T?> open<T>(BuildContext context) async {
  //   return context.axeSheet<T>(this, enableDrag: false);
  // }

  @override
  Widget build(
    BuildContext context,
  ) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final gradYear = useState(DateTime.now());
    final isNewUser = useState(true);

    return AxSteppedPage(
      title: 'Create Account',
      init: () {
        //appConfigProvider.update((config) => config.copyWith(isDoingOnboarding: true));
      },
      onClose: () {
        ///appConfigProvider.update((config) => config.copyWith(isDoingOnboarding: false));
        context.Pop();
      },
      useProgressIndicatorInsteadOfSteps: true,
      completedBody: Container(
        height: 400,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            kVSpace64,
            kVSpace64,
            kVSpace64,
            const Text('${'You are all set up'}! 🎉',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, height: 1.3, color: Colors.white)),
            kVSpace24,
            AxButton(
              title: 'Click to start',
              color: AxButtonColor.primary,
              onTap: () {
                //context.axPop();
                context.replacePage(const HomeScreen()
                    // AxSignUpScreen(logo: widget.logo),
                    );
                //appConfigProvider.update((config) => config.copyWith(isDoingOnboarding: false));
                //context.axPop();
              },
            ),
            kVSpace64,
          ],
        ),
      ),
      steps: [
        // const AxStep(
        //   content: AxFirstStep(),
        //   nextTitle: "Let's Start!",
        // ),

        /// Email
        AxStep(
          title: 'My email is ...',
          content: AxTextField.email(
            controller: emailController,
          ),
          onNext: () async {
            // final isEmailValid = SupabaseService.isEmail(emailController.text);
            // if (!isEmailValid) {
            //   Alert(
            //     emoji: '🙈',
            //     mainText: 'Bad email',
            //     secondaryText: 'Please enter a valid email address',
            //     buttonTitle: 'Try again',
            //   ).show(context);
            //   return false;
            // }

            // if (AuthService().user?.email == emailController.text) {
            //   return true;
            // }

            /// demo@axenda.io
            // final result = await context.showLoadingWhileRunning(
            //   function: () => AxKhottaApiService().post('auth/is-email-used', {'email': emailController.text}),

            // );
            // String? error;
            // error = await SupabaseService().signUpWithEmail(emailController.text, passwordController.text);
            // if (error != null) {
            //   Alert(
            //     mainText: error,
            //     emoji: '🙈',
            //   ).show(context);
            //   return false;
            // }

            // final isRegistered = (result.data?['is_registered'] as bool?) ?? false;
            // isNewUser.value = !isRegistered;

            return true;
          },
        ),
        AxStep(
          title: 'My password is ...',
          content: AxTextField.password(
            controller: passwordController,
            onEditingComplete: (_) {},
          ),
          onNext: () async {
            // if (AuthService().user?.email == emailController.text) {
            //   return true;
            // }

            // String? error;
            // if (isNewUser.value) {
            //   final isPasswordValid = passwordController.text.trim().length > 7;
            //   if (!isPasswordValid) {
            //     Alert(
            //       emoji: '🙈',
            //       mainText: 'Short password',
            //       secondaryText: 'Please enter a longer password',
            //       buttonTitle: 'Try again',
            //     ).show(context);
            //     return false;
            //   }

            //   error = await SupabaseService.signUpWithEmail(emailController.text, passwordController.text);
            // }

            // if (error != null) {
            //   Alert(
            //     mainText: error,
            //     emoji: '🙈',
            //   ).show(context);
            //   return false;
            // }

            return true;
          },
        ),

        const AxStep(content: AxProfileStep()),

        // const AxStep(content: AxSecretHubStep()),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safewalk/data/models/user_model.dart';
import 'package:safewalk/data/services/firestore_service.dart';
import 'package:safewalk/views/pages/loading_page.dart';
import 'package:safewalk/views/pages/welcome_page.dart';
import 'package:safewalk/views/pages/twelcome_page.dart';

/// Routes users to the correct home page based on their UserType in Firestore
class UserTypeRouter extends StatelessWidget {
  const UserTypeRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Should not happen if called from AuthLayout
      return const LoadingPage();
    }

    return FutureBuilder<UserModel?>(
      future: FirestoreService().getUserProfile(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingPage();
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          // If user doesn't have a Firestore profile yet (e.g., Google sign-in),
          // default to visuallyImpaired view
          return const WelcomePage();
        }

        final userModel = snapshot.data!;

        // Route based on user type
        if (userModel.userType == UserType.emergencyContact) {
          return const TwelcomePage();
        } else {
          return const WelcomePage();
        }
      },
    );
  }
}

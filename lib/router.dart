import 'package:doccs/featurs/auth/screens/login_screen.dart';
import 'package:doccs/featurs/document/screens/document_screen.dart';
import 'package:doccs/featurs/home/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

final loggedOutRoute = RouteMap(routes: {
  '/': (route) => const MaterialPage(child: LoginScreen()),
});

final loggedInRoute = RouteMap(routes: {
  '/': (route) => const MaterialPage(child: HomeScreen()),
  '/document/:id': (route) => MaterialPage(
        child: DocumentScreen(id: route.pathParameters['id'] ?? ""),
      )
});

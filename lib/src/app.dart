import 'package:flutter/material.dart';
import 'dart:math';

import 'routing.dart';
import 'screens/navigator.dart';

class Bookstore extends StatefulWidget {
	const Bookstore({super.key});

	@override
	State<Bookstore> createState() => _BookstoreState();
}

class _BookstoreState extends State<Bookstore> {
	final _navigatorKey = GlobalKey<NavigatorState>();
	late final RouteState _routeState;
	late final SimpleRouterDelegate _routerDelegate;
	late final TemplateRouteParser _routeParser;

	@override
	void initState() {
		/// Configure the parser with all of the app's allowed path templates.
		_routeParser = TemplateRouteParser(
			allowedPaths: [
				'/schedules',
        '/schedules/:navpos',
				'/trafic',
        '/trafic/:lineId',
				'/books/new',
				'/books/all',
				'/books/popular',
				'/book/:bookId',
				'/author/:authorId',
			],
			initialRoute: '/schedules',
		);

		_routeState = RouteState(_routeParser);

		_routerDelegate = SimpleRouterDelegate(
			routeState: _routeState,
			navigatorKey: _navigatorKey,
			builder: (context) => BookstoreNavigator(
				navigatorKey: _navigatorKey,
			),
		);

		super.initState();
	}

	@override
	Widget build(BuildContext context) => RouteStateScope(
				notifier: _routeState,
				child: MaterialApp.router(
						routerDelegate: _routerDelegate,
						routeInformationParser: _routeParser,
						// Revert back to pre-Flutter-2.5 transition behavior:
						// https://github.com/flutter/flutter/issues/82053
						theme: ThemeData(
							primarySwatch: generateMaterialColor(Color(0xff135a75)), // generateMaterialColor(Color(0xff08007c))
							pageTransitionsTheme: const PageTransitionsTheme(
								builders: {
									TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
									TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
									TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
									TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
									TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
								},
							),
						),
					),
			);
}


MaterialColor generateMaterialColor(Color color) {
	return MaterialColor(color.value, {
		50: tintColor(color, 0.9),
		100: tintColor(color, 0.8),
		200: tintColor(color, 0.6),
		300: tintColor(color, 0.4),
		400: tintColor(color, 0.2),
		500: color,
		600: shadeColor(color, 0.1),
		700: shadeColor(color, 0.2),
		800: shadeColor(color, 0.3),
		900: shadeColor(color, 0.4),
	});
}

int tintValue(int value, double factor) =>
		max(0, min((value + ((255 - value) * factor)).round(), 255));

Color tintColor(Color color, double factor) => Color.fromRGBO(
		tintValue(color.red, factor),
		tintValue(color.green, factor),
		tintValue(color.blue, factor),
		1);

int shadeValue(int value, double factor) =>
		max(0, min(value - (value * factor).round(), 255));

Color shadeColor(Color color, double factor) => Color.fromRGBO(
		shadeValue(color.red, factor),
		shadeValue(color.green, factor),
		shadeValue(color.blue, factor),
		1);
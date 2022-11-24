import 'package:flutter/material.dart';
import 'fav_scroll.dart';
import 'messages.dart';

class HomeBody extends StatelessWidget {
	final ScrollController scrollController;
	final List pointNearby;
  final Map index;

	const HomeBody({
		required this.scrollController,
		required this.pointNearby,
    required this.index,
		super.key,
	});

	@override
	Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.only(top:110),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(5),
      color: Colors.grey[200],
    ),
    child: Column(
      children: [
        const SizedBox(
          height: 80,
          child: HomeBodyFavScroll(),
        ),
        const SizedBox(
          height: 10,
        ),

        // Messages de l'index
        if (index['message'] != null)
          for (var message in index['message'])
            Home_Messages(
              message: message
            ),

        //
      ],
    )
  );
}
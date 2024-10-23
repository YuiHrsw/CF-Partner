import 'dart:math';
import 'package:flutter/material.dart';

class ContributionTileGrid extends StatefulWidget {
  final List<Color> contributionColors;
  final DateTime startDate;

  const ContributionTileGrid(
      {super.key, required this.contributionColors, required this.startDate});

  @override
  ContributionTileGridState createState() => ContributionTileGridState();
}

class ContributionTileGridState extends State<ContributionTileGrid> {
  late ScrollController _scrollController;
  int? _selectedTileIndex;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: List.generate(52, (weekIndex) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                children: List.generate(7, (dayIndex) {
                  int tileIndex = weekIndex * 7 + dayIndex;
                  int contributionLevel = Random().nextInt(5);
                  DateTime currentDate = widget.startDate.add(
                    Duration(days: tileIndex),
                  );

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTileIndex = tileIndex;
                      });
                    },
                    child: ContributionTile(
                      color: _selectedTileIndex == tileIndex
                          ? Colors.blue
                          : widget.contributionColors[contributionLevel],
                      date: currentDate,
                      isSelected: _selectedTileIndex == tileIndex,
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class ContributionTile extends StatelessWidget {
  final Color color;
  final DateTime date;
  final bool isSelected;

  const ContributionTile(
      {super.key,
      required this.color,
      required this.date,
      required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        // border: isSelected
        //     ? Border.all(color: Colors.red, width: 2)
        //     : null,
      ),
    );
  }
}

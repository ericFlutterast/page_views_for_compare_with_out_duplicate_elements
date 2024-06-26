import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      home: MyApp(),
    ),
  );
}

final List<Color> _colors = [
  Colors.deepOrange,
  Colors.pink,
  for (int i = 0; i < 4; i++)
    Color.fromRGBO(Random().nextInt(255), Random().nextInt(255), Random().nextInt(255), 1)
];

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late List<Offer> _leftOffers;
  late List<Offer> _rightOffers;

  late Offer removedFromLeft;
  late Offer removedFromRight;

  late final PageController _leftController;
  late final PageController _rightController;

  int currentLeftIndex = 0;
  int currentRightIndex = 0;

  @override
  void initState() {
    super.initState();

    final items = _colors.mapIndexed((index, color) => Offer(indexForShow: index, color: color)).toList();

    var temp = [...items];
    removedFromLeft = temp.removeAt(1);
    _leftOffers = temp;

    temp = [...items];
    removedFromRight = temp.removeAt(0);
    _rightOffers = temp;

    print(1000 % _rightOffers.length);

    _leftController = PageController(initialPage: 1000 - 1000 % _rightOffers.length);
    _rightController = PageController(initialPage: 1000 - 1000 % _rightOffers.length);
  }

  Offer _replaceSimilarElementRight({
    required final int index,
    required List<Offer> handleList,
    required List<Offer> changedList,
    required Offer removedElement,
  }) {
    final indexToInsertSimilarElement = changedList.indexOf(handleList[index]);
    changedList[indexToInsertSimilarElement] = removedElement;
    return handleList[index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          height: 400,
          child: Center(
            child: Row(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _leftController,
                    onPageChanged: (index) {
                      //заносим в противоположный список элемент который теперь отображается в списке
                      final removedRight = _replaceSimilarElementRight(
                        index: index % _leftOffers.length,
                        handleList: _leftOffers,
                        changedList: _rightOffers,
                        removedElement: removedFromRight,
                      );

                      final res = _restoreCorrectSequence(
                        index: index % _leftOffers.length,
                        currentShowElementIndex: currentRightIndex,
                        handleList: _leftOffers,
                        changedList: _rightOffers,
                      );

                      setState(() {
                        currentLeftIndex = index % _leftOffers.length;
                        removedFromRight = removedRight;
                        _leftOffers = res.handleList;
                        _rightOffers = res.changedList;
                      });
                    },
                    itemBuilder: (context, index) {
                      final item = _leftOffers[index % _leftOffers.length];

                      return Container(
                        color: item.color,
                        child: Center(
                          child: Text(
                            item.indexForShow.toString(),
                            style: const TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _rightController,
                    onPageChanged: (index) {
                      //заносим в противоположный список элемент который теперь отображается в списке
                      final removedLeft = _replaceSimilarElementRight(
                        index: index % _leftOffers.length,
                        handleList: _rightOffers,
                        changedList: _leftOffers,
                        removedElement: removedFromLeft,
                      );

                      final res = _restoreCorrectSequence(
                        index: index % _rightOffers.length,
                        currentShowElementIndex: currentLeftIndex,
                        handleList: _rightOffers,
                        changedList: _leftOffers,
                      );

                      setState(() {
                        currentRightIndex = index % _rightOffers.length;
                        removedFromLeft = removedLeft;
                        _rightOffers = res.handleList;
                        _leftOffers = res.changedList;
                      });
                    },
                    itemBuilder: (context, index) {
                      final item = _rightOffers[index % _rightOffers.length];

                      return Container(
                        color: item.color,
                        child: Center(
                          child: Text(
                            item.indexForShow.toString(),
                            style: const TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ({List<Offer> handleList, List<Offer> changedList}) _restoreCorrectSequence({
    required final int index,
    required final int currentShowElementIndex,
    required final List<Offer> handleList,
    required List<Offer> changedList,
  }) {
    final Offer currentShowElement = changedList[currentShowElementIndex];
    changedList.sort((a, b) => a.indexForShow.compareTo(b.indexForShow));

    if (changedList[currentShowElementIndex] == currentShowElement) {
      return (handleList: handleList, changedList: changedList);
    }

    final currentShowElementIndexAfterSort = changedList.indexOf(currentShowElement);

    final int changedListLength = changedList.length;
    final int indexOffset = currentShowElementIndexAfterSort - currentShowElementIndex;
    if (indexOffset < 0) {
      rotate<Offer>(changedList, indexOffset * -1);
    } else {
      final List<Offer> restoredPositionList = [];

      for (int i = indexOffset; i < changedListLength; i++) {
        restoredPositionList.add(changedList.removeAt(indexOffset));
      }

      restoredPositionList.addAll(changedList);
      changedList = restoredPositionList;
    }

    return (handleList: handleList, changedList: changedList);
  }

  void rotate<T>(List<T> nums, int k) {
    k %= nums.length;

    List<T> result = [];
    if (nums.length > 1 && k > 0) {
      result = nums.getRange(nums.length - k, nums.length).toList();

      for (int i = 0; i < nums.length - k; i++) {
        result.add(nums[i]);
      }

      nums.removeRange(0, nums.length);
      nums.insertAll(0, result);
    }
  }
}

final class Offer {
  const Offer({
    required this.indexForShow,
    required this.color,
  });

  final Color color;
  final int indexForShow;

  @override
  int get hashCode => Object.hashAll([color, indexForShow]);

  @override
  bool operator ==(Object other) {
    return other is Offer &&
        other.runtimeType == runtimeType &&
        other.indexForShow == indexForShow &&
        other.color == color;
  }

  bool operator >(Object other) {
    return other is Offer && other.runtimeType == runtimeType && other.indexForShow < indexForShow;
  }
}

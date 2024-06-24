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

  //left handler handle right
  ({List<Offer> handleList, List<Offer> changedList}) _restoreCorrectSequence({
    required final int index,
    required final int currentShowElementIndex,
    required final List<Offer> handleList, //left
    required List<Offer> changedList, //right
  }) {
    //сохраняем позициию отоброжаемого элемента и
    // сам элемент для востановления его позиции после сортировки
    final Offer currentShowElement = changedList[currentShowElementIndex];
    //сортировака для восстановдения правильной последжовательности
    changedList.sort((a, b) => a.indexForShow.compareTo(b.indexForShow));

    //если элемент в нужной позиции
    if (changedList[currentShowElementIndex].indexForShow == currentShowElement.indexForShow) {
      return (handleList: handleList, changedList: changedList);
    }

    //rename //список для востановления позиции отображения
    final List<Offer> fixedPositionRightOffers = [];

    //rename// нидекс элемента который отображается в отсортированном массиве
    final currentShowElementAfterSort = changedList.indexOf(currentShowElement);

    //rename
    final int end = changedList.length; //конец списка отображаемых элементов
    //начало элемента с которых нужно начать вставку чтобы востановить позцию
    int start = currentShowElementAfterSort - currentShowElementIndex;

    //если целевая позиции будет находиться слева от текущий позиции после сортировки,
    //то в start получится отрицательное число поэтому делаем его положительным умнодая на -1
    if (start < 0) {
      rotate<Offer>(changedList, start * -1);
    } else {
      //вставляем элементы в новый список
      for (int i = start; i < end; i++) {
        fixedPositionRightOffers.add(changedList.removeAt(start));
      }

      //в конец ставляем все что осталось чтобы сохранить последовательность в беконечом пейдж вью
      fixedPositionRightOffers.addAll(changedList);

      //присвоить _leftOffers новый список
      changedList = fixedPositionRightOffers;
    }

    return (handleList: handleList, changedList: changedList);
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

                      //_rightOffersHandler(index % _rightOffers.length);
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

//right handler handle left
// void _rightOffersHandler(int rightIndex) {
//   setState(() {
//     // сохраняем позицию отображаемого элемента чтобы его востановсить
//     final int currentShowElementIndex = currentLeftIndex;
//     //отображаемый элемент
//     final Offer currentShowElement = _leftOffers[currentShowElementIndex];
//
//     final putIndex = _leftOffers.indexOf(_rightOffers[rightIndex]);
//     _leftOffers[putIndex] = removedFromLeft;
//     removedFromLeft = _rightOffers[rightIndex];
//
//     _leftOffers.sort((a, b) => a.indexForShow.compareTo(b.indexForShow));
//
//     if (_leftOffers[currentShowElementIndex].indexForShow == currentShowElement.indexForShow) {
//       return;
//     }
//     //rename //список для востановления позиции отображения
//     final List<Offer> fixedPositionLeftOffers = [];
//     //rename// нидекс элемента который отображается в отсортированном массиве
//     final currentShowElementAfterSort = _leftOffers.indexOf(currentShowElement);
//     //rename
//     final int end = _leftOffers.length; //конец списка отображаемых элементов
//     //начало элемента с которых нужно начать вставку чтобы востановить позцию
//     int start = currentShowElementAfterSort - currentShowElementIndex;
//     //если целевая позиции будет находиться слева от текущий позиции после сортировки,
//     //то в start получится отрицательное число поэтому делаем его положительным умнодая на -1
//     if (start < 0) {
//       rotate<Offer>(_leftOffers, start * -1);
//     } else {
//       //вставляем элементы в новый список
//       for (int i = start; i < end; i++) {
//         fixedPositionLeftOffers.add(_leftOffers.removeAt(start));
//       }
//       //в конец ставляем все что осталось чтобы сохранить последовательность в беконечом пейдж вью
//       fixedPositionLeftOffers.addAll(_leftOffers);
//       //присвоить _leftOffers новый список
//       _leftOffers = fixedPositionLeftOffers;
//     }
//   });
// }

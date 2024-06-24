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
  for (int i = 0; i < 1; i++)
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

    _showCurrentState();
  }

  //left handler handle right
  void _leftOffersHandler(int leftIndex) {
    print('_leftOffersHandler');
    //
    // //1
    // if (currentRightIndex == 0) {
    //   setState(() {
    //     _rightOffers.add(removedFromRight);
    //
    //     removedFromRight = _leftOffers[leftIndex];
    //     _rightOffers.remove(removedFromRight);
    //
    //     insertionSort(
    //       _rightOffers,
    //       start: 1,
    //       end: _leftOffers.length,
    //       compare: (a, b) {
    //         if (a.indexForShow == 0) {
    //           return 1;
    //         }
    //
    //         return a.indexForShow.compareTo(b.indexForShow);
    //       },
    //     );
    //   });
    //
    //   if (_rightOffers.contains(removedFromRight)) {
    //     throw Exception('Содержит элемент который должен был удалится _leftOffersHandler() condition 1');
    //   }
    //
    //   print(1);
    //   _showCurrentState();
    //   return;
    // }
    //
    // //2
    // if (currentRightIndex == _rightOffers.length - 1) {
    //   setState(() {
    //     _rightOffers = [removedFromRight, ..._rightOffers];
    //
    //     removedFromRight = _leftOffers[leftIndex];
    //     _rightOffers.remove(removedFromRight);
    //
    //     insertionSort(
    //       _rightOffers,
    //       start: 0,
    //       end: _rightOffers.length - 1,
    //       compare: (a, b) => a.indexForShow.compareTo(b.indexForShow),
    //     );
    //   });
    //
    //   if (_rightOffers.contains(removedFromRight)) {
    //     throw Exception('Содержит элемент который должен был удалится _leftOffersHandler() condition 2');
    //   }
    //
    //   print(2);
    //   _showCurrentState();
    //   return;
    // }

    //3 currentRightIndex > 0 && currentRightIndex < _rightOffers.length - 1
    if (true) {
      setState(() {
        _showCurrentState();

        final int currentShowElementIndex = currentRightIndex;
        final Offer currentShowElement = _rightOffers[currentShowElementIndex];

        final putIndex = _rightOffers.indexOf(_leftOffers[leftIndex]);
        _rightOffers[putIndex] = removedFromRight;
        removedFromRight = _leftOffers[leftIndex];

        _showCurrentState();

        _rightOffers.sort((a, b) => a.indexForShow.compareTo(b.indexForShow));

        if (_rightOffers[currentShowElementIndex].indexForShow == currentShowElement.indexForShow) {
          return;
        }

        //rename //список для востановления позиции отображения
        final List<Offer> fixedPositionRightOffers = [];

        //rename// нидекс элемента который отображается в отсортированном массиве
        final currentShowElementAfterSort = _rightOffers.indexOf(currentShowElement);

        //rename
        final int end = _rightOffers.length; //конец списка отображаемых элементов
        //начало элемента с которых нужно начать вставку чтобы востановить позцию
        int start = currentShowElementAfterSort - currentShowElementIndex;

        //если целевая позиции будет находиться слева от текущий позиции после сортировки,
        //то в start получится отрицательное число поэтому делаем его положительным умнодая на -1
        if (start < 0) {
          rotate<Offer>(_rightOffers, start * -1);
        } else {
          //вставляем элементы в новый список
          for (int i = start; i < end; i++) {
            fixedPositionRightOffers.add(_rightOffers.removeAt(start));
          }

          //в конец ставляем все что осталось чтобы сохранить последовательность в беконечом пейдж вью
          fixedPositionRightOffers.addAll(_rightOffers);

          //присвоить _leftOffers новый список
          _rightOffers = fixedPositionRightOffers;
        }

        print(3);
        _showCurrentState();
      });
    }
  }

  //right handler handle left
  void _rightOffersHandler(int rightIndex) {
    print('_leftOffersHandler');
    //
    // //1
    // if (currentLeftIndex == 0) {
    //   setState(() {
    //     _leftOffers.add(removedFromLeft);
    //
    //     removedFromLeft = _rightOffers[rightIndex];
    //     _leftOffers.remove(removedFromLeft);
    //
    //     insertionSort(
    //       _leftOffers,
    //       start: 1,
    //       end: _leftOffers.length,
    //       compare: (a, b) {
    //         if (a.indexForShow == 0) {
    //           return 1;
    //         }
    //         return a.indexForShow.compareTo(b.indexForShow);
    //       },
    //     );
    //   });
    //
    //   print(1);
    //   _showCurrentState();
    //   return;
    // }
    //
    // //2
    // if (currentLeftIndex == _leftOffers.length - 1) {
    //   setState(() {
    //     _leftOffers = [removedFromLeft, ..._leftOffers];
    //
    //     removedFromLeft = _rightOffers[rightIndex];
    //     _leftOffers.remove(removedFromLeft);
    //
    //     insertionSort(
    //       _leftOffers,
    //       start: 0,
    //       end: _leftOffers.length - 1,
    //       compare: (a, b) => a.indexForShow.compareTo(b.indexForShow),
    //     );
    //   });
    //
    //   print(2);
    //   _showCurrentState();
    //   return;
    // }

    //3 currentLeftIndex > 0 && currentLeftIndex < _leftOffers.length - 1
    if (true) {
      setState(() {
        _showCurrentState();

        // сохраняем позицию отображаемого элемента чтобы его востановсить
        final int currentShowElementIndex = currentLeftIndex;
        //отображаемый элемент
        final Offer currentShowElement = _leftOffers[currentShowElementIndex];

        final putIndex = _leftOffers.indexOf(_rightOffers[rightIndex]);
        _leftOffers[putIndex] = removedFromLeft;
        removedFromLeft = _rightOffers[rightIndex];

        _showCurrentState();

        _leftOffers.sort((a, b) => a.indexForShow.compareTo(b.indexForShow));

        if (_leftOffers[currentShowElementIndex].indexForShow == currentShowElement.indexForShow) {
          return;
        }

        //rename //список для востановления позиции отображения
        final List<Offer> fixedPositionLeftOffers = [];

        //rename// нидекс элемента который отображается в отсортированном массиве
        final currentShowElementAfterSort = _leftOffers.indexOf(currentShowElement);

        //rename
        final int end = _leftOffers.length; //конец списка отображаемых элементов
        //начало элемента с которых нужно начать вставку чтобы востановить позцию
        int start = currentShowElementAfterSort - currentShowElementIndex;

        //если целевая позиции будет находиться слева от текущий позиции после сортировки,
        //то в start получится отрицательное число поэтому делаем его положительным умнодая на -1
        if (start < 0) {
          rotate<Offer>(_leftOffers, start * -1);
        } else {
          //вставляем элементы в новый список
          for (int i = start; i < end; i++) {
            fixedPositionLeftOffers.add(_leftOffers.removeAt(start));
          }

          //в конец ставляем все что осталось чтобы сохранить последовательность в беконечом пейдж вью
          fixedPositionLeftOffers.addAll(_leftOffers);

          //присвоить _leftOffers новый список
          _leftOffers = fixedPositionLeftOffers;
        }
      });

      print(3);
      _showCurrentState();
    }
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
                      setState(() {
                        currentLeftIndex = index % _leftOffers.length;
                      });

                      _leftOffersHandler(index % _leftOffers.length);
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
                      setState(() {
                        currentRightIndex = index % _rightOffers.length;
                      });

                      _rightOffersHandler(index % _rightOffers.length);
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
    final List<T> temp = [];
    final List<T> temp2 = [];

    if (k > nums.length) {
      k %= nums.length;
    }

    for (int i = 0; i < nums.length; i++) {
      if (i < nums.length - k) {
        temp.add(nums[i]);
        continue;
      }

      temp2.add(nums[i]);
    }

    int tempLengthCount = 0;
    int tempLengthTwoCount = 0;
    for (int i = 0; i < nums.length; i++) {
      if (tempLengthTwoCount < temp2.length) {
        nums[i] = temp2[tempLengthTwoCount];
        tempLengthTwoCount++;
        continue;
      }

      if (tempLengthCount < temp.length) {
        nums[i] = temp[tempLengthCount];
        tempLengthCount++;
        continue;
      }
    }
  }

  //TODO:
  void _showCurrentState() {
    print('removedFromLeft: ${removedFromLeft.indexForShow}');
    print('removedFromRight: ${removedFromRight.indexForShow}');

    print('currentLeftIndex: $currentLeftIndex');
    print('currentRightIndex: $currentRightIndex');

    String a = '';
    for (final item in _leftOffers) {
      a += '${item.indexForShow} ';
    }

    String b = '';
    for (final item in _rightOffers) {
      b += '${item.indexForShow} ';
    }

    print('left = [$a]');
    print('right = [$b]');
    print('--------------------------------');
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

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: Padding(
        padding: const EdgeInsets.only(left: 24, top: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Your Notes",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 46,
                      fontWeight: FontWeight.w300),
                ),
                Container(
                  height: 50,
                  width: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  margin: const EdgeInsets.only(right: 24),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12)),
                  child: SvgPicture.asset(
                    'assets/icons/Plus.svg',
                    color: Colors.white,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            Container(
              height: 30,
              width: 120,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6), color: Colors.white),
              child: Row(
                children: [
                  const Text(
                    "Personal",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    width: 14,
                  ),
                  SvgPicture.asset(
                    'assets/icons/ChevronDown.svg',
                    height: 18,
                    width: 18,
                  )
                ],
              ),
            )
          ],
        ),
      ),
      backgroundColor: Colors.black,
    );
  }

  AppBar appBar() {
    return AppBar(
      backgroundColor: Colors.black,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Welcome back User",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Poppins'),
                  ),
                ],
              ),
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/Search.svg',
                    height: 20,
                    width: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  SvgPicture.asset(
                    'assets/icons/Bell.svg',
                    height: 20,
                    width: 20,
                    color: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:absensi/screens/scan_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              width: MediaQuery.of(context).size.width * 0.6,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: TextField(
                controller: textEditingController,
                keyboardType: TextInputType.number,
                autocorrect: false,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(10),
                  hintText: "Sesi (ex: 1)",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () {
              if (textEditingController.text == "" ||
                  textEditingController.text == "0") {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text("Sesi tidak boleh kosong!"),
                  backgroundColor: Theme.of(context).errorColor,
                  duration: const Duration(milliseconds: 500),
                ));
                return;
              }

              Navigator.of(context).push(MaterialPageRoute(
                  builder: ((context) => ScanScreen(
                        sesi: int.parse(textEditingController.text),
                      ))));
            },
            child: const Text("Scan QR"),
          ),
        ],
      ),
    );
  }
}

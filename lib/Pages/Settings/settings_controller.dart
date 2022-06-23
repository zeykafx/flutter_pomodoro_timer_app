import 'package:get/get.dart';

class SettingsController extends GetxController {
  RxBool blockSite = false.obs;
  RxList<String> sitesToBlock = <String>[].obs;
}
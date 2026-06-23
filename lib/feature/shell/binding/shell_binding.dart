import 'package:Ok/feature/customers/bindings/customers_binding.dart';
import 'package:Ok/feature/dashboard/bindings/dashboard_binding.dart';
import 'package:Ok/feature/due_tracking/bindings/due_tracking_binding.dart';
import 'package:Ok/feature/meetings/bindings/meetings_binding.dart';
import 'package:Ok/feature/notes/bindings/notes_binding.dart';
import 'package:Ok/feature/price_list/bindings/price_list_binding.dart';
import 'package:Ok/feature/price_offers/bindings/price_offers_binding.dart';
import 'package:Ok/feature/reminders/bindings/reminders_binding.dart';
import 'package:Ok/feature/scrap_quality/bindings/scrap_quality_binding.dart';
import 'package:Ok/feature/settings/binding/settings_binding.dart';
import 'package:Ok/feature/shell/controller/shell_controller.dart';
import 'package:get/get.dart';

final class ShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShellController>(ShellController.new);
    RemindersBinding().dependencies();
    DashboardBinding().dependencies();
    SettingsBinding().dependencies();
    CustomersBinding().dependencies();
    DueTrackingBinding().dependencies();
    MeetingsBinding().dependencies();
    ScrapQualityBinding().dependencies();
    NotesBinding().dependencies();
    PriceOffersBinding().dependencies();
    PriceListBinding().dependencies();
    RemindersBinding().dependencies();
  }
}

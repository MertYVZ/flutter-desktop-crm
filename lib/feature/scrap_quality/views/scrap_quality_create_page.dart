import 'package:Ok/feature/due_tracking/models/currency_type.dart';
import 'package:Ok/feature/scrap_quality/controllers/scrap_quality_controller.dart';
import 'package:Ok/feature/scrap_quality/models/scrap_lost_reason.dart';
import 'package:Ok/feature/scrap_quality/models/scrap_sales_status.dart';
import 'package:Ok/feature/scrap_quality/models/scrap_quality_unit.dart';
import 'package:Ok/feature/scrap_quality/widgets/scrap_quality_form.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/navigation/app_route_args.dart';
import 'package:Ok/product/state/base/state/base_state.dart';
import 'package:Ok/product/state/base/view/base_view.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:Ok/product/widgets/panel/panel_message.dart';
import 'package:Ok/product/widgets/panel/panel_form_page_header.dart';
import 'package:Ok/product/widgets/panel/panel_form_scroll_view.dart';
import 'package:Ok/product/widgets/panel/panel_surface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final class ScrapQualityCreatePage extends StatefulWidget {
  const ScrapQualityCreatePage({super.key});

  @override
  State<ScrapQualityCreatePage> createState() => _ScrapQualityCreatePageState();
}

class _ScrapQualityCreatePageState extends BaseState<ScrapQualityCreatePage> {
  late final TextEditingController _scrapTypeController;
  late final TextEditingController _qualityController;
  late final TextEditingController _quantityController;
  late final TextEditingController _customUnitController;
  late final TextEditingController _quantityKgController;
  late final TextEditingController _cityController;
  late final TextEditingController _offerPriceController;
  late final TextEditingController _targetPriceController;
  late final TextEditingController _customLostReasonController;
  late final TextEditingController _noteController;

  String? _selectedCustomerId;
  ScrapQualityUnit? _selectedUnit = ScrapQualityUnit.defaultUnit;
  ScrapSalesStatus? _selectedSalesStatus = ScrapSalesStatus.unresolved;
  CurrencyType? _selectedCurrency = CurrencyType.try_;
  ScrapLostReason? _selectedLostReason;
  DateTime? _recordDate;
  DateTime? _followUpDate;

  @override
  void initState() {
    super.initState();
    _selectedCustomerId = AppRouteArgs.readCustomerId();
    _recordDate = AppDateUtils.normalizeDate(DateTime.now());
    _scrapTypeController = TextEditingController();
    _qualityController = TextEditingController();
    _quantityController = TextEditingController();
    _customUnitController = TextEditingController();
    _quantityKgController = TextEditingController();
    _cityController = TextEditingController();
    _offerPriceController = TextEditingController();
    _targetPriceController = TextEditingController();
    _customLostReasonController = TextEditingController();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _scrapTypeController.dispose();
    _qualityController.dispose();
    _quantityController.dispose();
    _customUnitController.dispose();
    _quantityKgController.dispose();
    _cityController.dispose();
    _offerPriceController.dispose();
    _targetPriceController.dispose();
    _customLostReasonController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<ScrapQualityController>(
      viewModel: Get.find<ScrapQualityController>(),
      onModelReady: (controller) {
        controller.clearMessages();
        controller.loadCustomersForDropdown();
        controller.loadFilterOptions();
      },
      onPageBuilder: (context, controller) {
        return PanelFormScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PanelFormPageHeader(
                title: 'Yeni Hurda Kaydı',
                subtitle: 'Aylık hurda takip kaydı oluşturun.',
                onBack: () => Get.offNamed<void>(AppRoutes.scrapQuality.value),
              ),
              const SizedBox(height: AppUiTokens.space16),
              Obx(() {
                final error = controller.errorMessage.value;
                final success = controller.successMessage.value;
                if (error == null && success == null) {
                  return const SizedBox.shrink();
                }

                return Column(
                  children: [
                    if (error != null) PanelMessage(message: error),
                    if (error != null && success != null)
                      const SizedBox(height: AppUiTokens.space8),
                    if (success != null)
                      PanelMessage(
                        message: success,
                        type: PanelMessageType.info,
                      ),
                    const SizedBox(height: AppUiTokens.space16),
                  ],
                );
              }),
              PanelSurface(
                padding: const EdgeInsets.all(AppUiTokens.space24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Obx(
                      () => ScrapQualityForm(
                        customers: controller.customers.toList(),
                        selectedCustomerId: _selectedCustomerId,
                        scrapTypeController: _scrapTypeController,
                        qualityController: _qualityController,
                        quantityController: _quantityController,
                        selectedUnit: _selectedUnit,
                        customUnitController: _customUnitController,
                        quantityKgController: _quantityKgController,
                        recordDate: _recordDate,
                        cityController: _cityController,
                        selectedSalesStatus: _selectedSalesStatus,
                        offerPriceController: _offerPriceController,
                        targetPriceController: _targetPriceController,
                        selectedCurrency: _selectedCurrency,
                        selectedLostReason: _selectedLostReason,
                        customLostReasonController: _customLostReasonController,
                        followUpDate: _followUpDate,
                        noteController: _noteController,
                        onCustomerChanged: (value) => setState(() {
                          _selectedCustomerId = value;
                        }),
                        onUnitChanged: (value) => setState(() {
                          _selectedUnit = value;
                        }),
                        onRecordDateChanged: (value) => setState(() {
                          _recordDate = value;
                        }),
                        onSalesStatusChanged: (value) => setState(() {
                          _selectedSalesStatus = value;
                        }),
                        onCurrencyChanged: (value) => setState(() {
                          _selectedCurrency = value;
                        }),
                        onLostReasonChanged: (value) => setState(() {
                          _selectedLostReason = value;
                        }),
                        onFollowUpDateChanged: (value) => setState(() {
                          _followUpDate = value;
                        }),
                      ),
                    ),
                    const SizedBox(height: AppUiTokens.space24),
                    Obx(
                      () => ScrapQualityFormActions(
                        isSaving: controller.isSaving.value,
                        onSave: controller.isSaving.value ||
                                controller.customers.isEmpty
                            ? null
                            : () => _submit(controller, closeAfterSave: true),
                        onSaveAndNew: controller.isSaving.value ||
                                controller.customers.isEmpty
                            ? null
                            : () => _submit(controller, closeAfterSave: false),
                        onCancel: controller.isSaving.value
                            ? () {}
                            : () => Get.offNamed<void>(
                                  AppRoutes.scrapQuality.value,
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submit(
    ScrapQualityController controller, {
    required bool closeAfterSave,
  }) async {
    final id = await controller.createRecord(
      customerId: _selectedCustomerId,
      scrapType: _scrapTypeController.text,
      qualityGrade: _qualityController.text,
      quantityText: _quantityController.text,
      unit: _selectedUnit,
      customUnitText: _customUnitController.text,
      quantityKgText: _quantityKgController.text,
      recordDate: _recordDate,
      salesStatus: _selectedSalesStatus,
      city: _cityController.text,
      offerPriceText: _offerPriceController.text,
      targetPriceText: _targetPriceController.text,
      currency: _selectedCurrency,
      lostReason: _selectedLostReason,
      customLostReasonText: _customLostReasonController.text,
      followUpDate: _followUpDate,
      note: _noteController.text,
    );

    if (id == null) {
      return;
    }

    if (closeAfterSave) {
      Get.offNamed<void>(AppRoutes.scrapQuality.value);
      return;
    }

    final preservedDate = _recordDate;
    final preservedCity = _cityController.text;
    final preservedScrapType = _scrapTypeController.text;
    final preservedQuality = _qualityController.text;
    final preservedStatus = _selectedSalesStatus;
    final preservedCurrency = _selectedCurrency;

    setState(() {
      _selectedCustomerId = null;
      _quantityController.clear();
      _customUnitController.clear();
      _quantityKgController.clear();
      _offerPriceController.clear();
      _targetPriceController.clear();
      _customLostReasonController.clear();
      _noteController.clear();
      _selectedLostReason = null;
      _followUpDate = null;
      _recordDate = preservedDate;
      _cityController.text = preservedCity;
      _scrapTypeController.text = preservedScrapType;
      _qualityController.text = preservedQuality;
      _selectedSalesStatus = preservedStatus;
      _selectedCurrency = preservedCurrency;
    });
  }
}

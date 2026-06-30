import 'dart:async';

import 'package:Ok/feature/due_tracking/models/currency_type.dart';
import 'package:Ok/feature/scrap_quality/controllers/scrap_quality_controller.dart';
import 'package:Ok/feature/scrap_quality/models/scrap_lost_reason.dart';
import 'package:Ok/feature/scrap_quality/models/scrap_sales_status.dart';
import 'package:Ok/feature/scrap_quality/models/scrap_quality_unit.dart';
import 'package:Ok/feature/scrap_quality/services/scrap_kg_utils.dart';
import 'package:Ok/feature/scrap_quality/widgets/scrap_quality_form.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/state/base/state/base_state.dart';
import 'package:Ok/product/state/base/view/base_view.dart';
import 'package:Ok/product/utility/constants/scrap_quality_messages.dart';
import 'package:Ok/product/utility/money_utils.dart';
import 'package:Ok/product/utility/quantity_utils.dart';
import 'package:Ok/product/widgets/panel/panel_message.dart';
import 'package:Ok/product/widgets/panel/panel_form_page_header.dart';
import 'package:Ok/product/widgets/panel/panel_form_scroll_view.dart';
import 'package:Ok/product/widgets/panel/panel_surface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final class ScrapQualityEditPage extends StatefulWidget {
  const ScrapQualityEditPage({super.key});

  @override
  State<ScrapQualityEditPage> createState() => _ScrapQualityEditPageState();
}

class _ScrapQualityEditPageState extends BaseState<ScrapQualityEditPage> {
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
  ScrapQualityUnit? _selectedUnit;
  ScrapSalesStatus? _selectedSalesStatus;
  CurrencyType? _selectedCurrency;
  ScrapLostReason? _selectedLostReason;
  DateTime? _recordDate;
  DateTime? _followUpDate;
  bool _isFormInitialized = false;

  String get _recordId => Get.parameters['id'] ?? '';

  @override
  void initState() {
    super.initState();
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

  void _populateForm(ScrapQualityRecord record) {
    if (_isFormInitialized) {
      return;
    }

    _selectedCustomerId = record.customerId;

    _scrapTypeController.text = record.quality;
    _qualityController.text = record.qualityGrade ?? '';
    _selectedCurrency =
        CurrencyTypeX.fromValue(record.currency) ?? CurrencyType.try_;

    _quantityController.text =
        QuantityUtils.formatQuantityInput(record.quantity);
    _quantityKgController.text =
        QuantityUtils.formatQuantityInput(record.quantityKg);
    _recordDate = record.recordDate;
    _cityController.text = record.city ?? '';
    _selectedSalesStatus = ScrapSalesStatusX.fromValue(record.salesStatus);
    _offerPriceController.text = record.offerPrice == null
        ? ''
        : MoneyUtils.formatAmountInput(record.offerPrice!);
    _targetPriceController.text = record.targetPrice == null
        ? ''
        : MoneyUtils.formatAmountInput(record.targetPrice!);
    _followUpDate = record.followUpDate;
    _noteController.text = record.note ?? '';

    final predefinedUnit = ScrapQualityUnit.fromLabel(record.unit);
    if (predefinedUnit != null) {
      _selectedUnit = predefinedUnit;
      _customUnitController.clear();
    } else {
      _selectedUnit = ScrapQualityUnit.other;
      _customUnitController.text = record.unit;
    }

    final lostReason = ScrapLostReasonX.fromValue(record.lostReason);
    if (lostReason != null) {
      _selectedLostReason = lostReason;
      if (lostReason == ScrapLostReason.other) {
        _customLostReasonController.text = record.lostReason ?? '';
      }
    } else if (record.lostReason != null && record.lostReason!.isNotEmpty) {
      _selectedLostReason = ScrapLostReason.other;
      _customLostReasonController.text = record.lostReason!;
    }

    _isFormInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<ScrapQualityController>(
      viewModel: Get.find<ScrapQualityController>(),
      onModelReady: (controller) {
        _isFormInitialized = false;
        unawaited(_loadRecord(controller));
      },
      onPageBuilder: (context, controller) {
        return Obx(() {
          if (controller.isLoading.value ||
              (controller.selectedRecord.value != null &&
                  !_isFormInitialized)) {
            return const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final record = controller.selectedRecord.value;
          if (record == null) {
            return Center(
              child: Text(
                controller.errorMessage.value ?? ScrapQualityMessages.notFound,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppUiTokens.textSecondary,
                    ),
              ),
            );
          }

          return PanelFormScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PanelFormPageHeader(
                  title: 'Hurda Kaydı Düzenle',
                  subtitle: record.quality,
                  onBack: () =>
                      Get.offNamed<void>(AppRoutes.scrapQuality.value),
                ),
                const SizedBox(height: AppUiTokens.space16),
                Obx(() {
                  final error = controller.errorMessage.value;
                  if (error == null) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    children: [
                      PanelMessage(message: error),
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
                          customLostReasonController:
                              _customLostReasonController,
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
                          showSaveAndNew: false,
                          onSave: controller.isSaving.value
                              ? null
                              : () => _submit(controller),
                          onSaveAndNew: null,
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
        });
      },
    );
  }

  Future<void> _loadRecord(ScrapQualityController controller) async {
    controller.clearMessages();
    await controller.loadCustomersForDropdown();
    await controller.loadFilterOptions();
    final loaded = await controller.getRecordById(_recordId);
    if (!loaded || !mounted) {
      return;
    }

    final record = controller.selectedRecord.value;
    if (record == null) {
      return;
    }

    setState(() {
      _populateForm(record);
    });
  }

  Future<void> _submit(ScrapQualityController controller) async {
    final success = await controller.updateRecord(
      id: _recordId,
      customerId: _selectedCustomerId,
      scrapType: _scrapTypeController.text,
      qualityGrade: _qualityController.text,
      quantityText: _quantityController.text,
      unit: _selectedUnit,
      customUnitText: _customUnitController.text,
      quantityKgText:
          _selectedUnit != null && ScrapKgUtils.requiresManualKg(_selectedUnit!)
              ? _quantityKgController.text
              : _quantityKgController.text,
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

    if (success) {
      Get.offNamed<void>(AppRoutes.scrapQuality.value);
    }
  }
}

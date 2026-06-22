import 'package:Ok/feature/auth/services/auth_service.dart';
import 'package:Ok/feature/price_offers/models/offer_pdf_settings.dart';
import 'package:Ok/feature/price_offers/models/offer_type.dart';
import 'package:Ok/feature/price_offers/services/legal_text_template_service.dart';
import 'package:Ok/feature/price_offers/services/offer_pdf_settings_service.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/service/database/database_backup_service.dart';
import 'package:Ok/product/utility/constants/auth_messages.dart';
import 'package:Ok/product/utility/constants/settings_messages.dart';
import 'package:Ok/product/utility/validators.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

/// Settings screen state and actions.
final class SettingsController extends GetxController {
  SettingsController(
    this._authService,
    this._databaseBackupService,
    this._offerPdfSettingsService,
    this._legalTextTemplateService,
  );

  final AuthService _authService;
  final DatabaseBackupService _databaseBackupService;
  final OfferPdfSettingsService _offerPdfSettingsService;
  final LegalTextTemplateService _legalTextTemplateService;

  final RxBool isChangingPassword = false.obs;
  final RxBool isBackingUp = false.obs;
  final RxBool isRestoring = false.obs;
  final RxBool isLoadingPdfSettings = false.obs;
  final RxBool isSavingPdfSettings = false.obs;
  final RxBool isLoadingLegalTemplates = false.obs;
  final RxBool isSavingLegalTemplate = false.obs;
  final Rxn<OfferPdfSettings> pdfSettings = Rxn<OfferPdfSettings>();
  final RxMap<OfferType, String> legalTemplates = <OfferType, String>{}.obs;
  final Rx<OfferType> selectedLegalTemplateType = OfferType.okTeknik.obs;
  final RxnString errorMessage = RxnString();
  final RxnString successMessage = RxnString();
  final RxBool obscureOldPassword = true.obs;
  final RxBool obscureNewPassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;

  bool get isLoading =>
      isChangingPassword.value ||
      isBackingUp.value ||
      isRestoring.value ||
      isLoadingPdfSettings.value ||
      isSavingPdfSettings.value ||
      isLoadingLegalTemplates.value ||
      isSavingLegalTemplate.value;

  bool get isBusy => isLoading;

  @override
  void onInit() {
    super.onInit();
    loadPdfSettings();
    loadLegalTemplates();
  }

  void clearMessages() {
    errorMessage.value = null;
    successMessage.value = null;
  }

  Future<void> loadPdfSettings() async {
    if (isLoadingPdfSettings.value) {
      return;
    }

    isLoadingPdfSettings.value = true;
    try {
      pdfSettings.value = await _offerPdfSettingsService.getAll();
    } catch (_) {
      errorMessage.value = SettingsMessages.pdfSettingsLoadError;
    } finally {
      isLoadingPdfSettings.value = false;
    }
  }

  Future<bool> savePdfSettings(OfferPdfSettings settings) async {
    if (isBusy) {
      errorMessage.value = SettingsMessages.concurrentOperation;
      return false;
    }

    clearMessages();

    final validationError = _validatePdfSettings(settings);
    if (validationError != null) {
      errorMessage.value = validationError;
      return false;
    }

    isSavingPdfSettings.value = true;
    try {
      await _offerPdfSettingsService.save(settings);
      pdfSettings.value = settings;
      successMessage.value = SettingsMessages.pdfSettingsSaved;
      return true;
    } catch (_) {
      errorMessage.value = SettingsMessages.pdfSettingsSaveError;
      return false;
    } finally {
      isSavingPdfSettings.value = false;
    }
  }

  Future<void> loadLegalTemplates() async {
    if (isLoadingLegalTemplates.value) {
      return;
    }

    isLoadingLegalTemplates.value = true;
    try {
      final templates = await _legalTextTemplateService.getAllTemplates();
      legalTemplates.assignAll(templates);
    } catch (_) {
      errorMessage.value = SettingsMessages.legalTemplateLoadError;
    } finally {
      isLoadingLegalTemplates.value = false;
    }
  }

  Future<bool> saveLegalTemplate({
    required OfferType type,
    required String content,
  }) async {
    if (isBusy) {
      errorMessage.value = SettingsMessages.concurrentOperation;
      return false;
    }

    clearMessages();

    if (content.trim().isEmpty) {
      errorMessage.value = SettingsMessages.legalTemplateRequired;
      return false;
    }

    isSavingLegalTemplate.value = true;
    try {
      final updated = await _legalTextTemplateService.updateTemplate(
        type: type,
        content: content.trim(),
      );
      if (!updated) {
        errorMessage.value = SettingsMessages.legalTemplateSaveError;
        return false;
      }

      legalTemplates[type] = content.trim();
      successMessage.value = SettingsMessages.legalTemplateSaved;
      return true;
    } catch (_) {
      errorMessage.value = SettingsMessages.legalTemplateSaveError;
      return false;
    } finally {
      isSavingLegalTemplate.value = false;
    }
  }

  void selectLegalTemplateType(OfferType type) {
    selectedLegalTemplateType.value = type;
  }

  String? _validatePdfSettings(OfferPdfSettings settings) {
    final requiredFields = <String, String>{
      'Tedarikçi firma adı': settings.supplierCompanyName,
      'Tedarikçi ilgili kişi': settings.supplierContactPerson,
      'Tedarikçi telefon': settings.supplierPhone,
      'Tedarikçi cep telefonu': settings.supplierMobilePhone,
      'Şirket unvanı': settings.companyLegalName,
      'Adres': settings.companyAddress,
      'Vergi bilgisi': settings.companyTaxInfo,
      'Ticaret sicil no': settings.companyTradeRegistry,
      'E-posta 1': settings.companyEmail1,
      'E-posta 2': settings.companyEmail2,
      'Telefon': settings.companyTel,
      'Faks': settings.companyFax,
    };

    for (final entry in requiredFields.entries) {
      if (entry.value.trim().isEmpty) {
        return '${entry.key}: ${SettingsMessages.pdfSettingsRequiredField}';
      }
    }

    return null;
  }

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (isBusy) {
      errorMessage.value = SettingsMessages.concurrentOperation;
      return false;
    }

    clearMessages();

    final validationError = _validatePasswordInputs(
      oldPassword: oldPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
    if (validationError != null) {
      errorMessage.value = validationError;
      return false;
    }

    isChangingPassword.value = true;
    try {
      await _authService.changePassword(oldPassword, newPassword);
      successMessage.value = SettingsMessages.passwordChanged;
      return true;
    } catch (error) {
      if (error is Exception) {
        errorMessage.value = error.toString().replaceFirst('Exception: ', '');
      } else if (error is StateError) {
        errorMessage.value = error.message;
      } else {
        errorMessage.value = AuthMessages.genericError;
      }
      return false;
    } finally {
      isChangingPassword.value = false;
    }
  }

  Future<void> backupDatabase() async {
    if (isBusy) {
      errorMessage.value = SettingsMessages.concurrentOperation;
      return;
    }

    clearMessages();
    isBackingUp.value = true;
    try {
      final didBackup = await _databaseBackupService.backupDatabase();
      if (didBackup) {
        successMessage.value = SettingsMessages.backupSuccess;
      }
    } on Exception catch (error) {
      errorMessage.value = error.toString().replaceFirst('Exception: ', '');
    } catch (_) {
      errorMessage.value = SettingsMessages.backupError;
    } finally {
      isBackingUp.value = false;
    }
  }

  Future<void> restoreDatabase() async {
    if (isBusy) {
      errorMessage.value = SettingsMessages.concurrentOperation;
      return;
    }

    clearMessages();

    final selectedPath = await _databaseBackupService.pickRestoreFile();
    if (selectedPath == null) {
      return;
    }

    if (!_isValidBackupFile(selectedPath)) {
      errorMessage.value = SettingsMessages.invalidBackupFile;
      return;
    }

    final confirmed = await _showRestoreConfirmDialog();
    if (!confirmed) {
      return;
    }

    isRestoring.value = true;
    try {
      await _databaseBackupService.restoreDatabase(selectedPath);
      successMessage.value = SettingsMessages.restoreSuccess;
    } on Exception catch (error) {
      errorMessage.value = error.toString().replaceFirst('Exception: ', '');
    } catch (_) {
      errorMessage.value = SettingsMessages.restoreError;
    } finally {
      isRestoring.value = false;
    }
  }

  String? _validatePasswordInputs({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    if (oldPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      return SettingsMessages.emptyPasswordFields;
    }

    if (newPassword.length < 8) {
      return PasswordValidationMessages.minLength;
    }

    final confirmationError =
        Validators.validatePasswordConfirmation(newPassword, confirmPassword);
    if (confirmationError != null) {
      return confirmationError;
    }

    if (oldPassword == newPassword) {
      return PasswordValidationMessages.sameAsOld;
    }

    return null;
  }

  bool _isValidBackupFile(String path) {
    return path.toLowerCase().endsWith('.sqlite');
  }

  Future<bool> _showRestoreConfirmDialog() async {
    final result = await Get.dialog<bool>(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: AppUiTokens.space24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppUiTokens.surface,
              borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
              border: Border.all(color: AppUiTokens.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppUiTokens.space24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(
                            AppUiTokens.radiusMd,
                          ),
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: ColorName.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: AppUiTokens.space16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              SettingsMessages.restoreConfirmTitle,
                              style: TextStyle(
                                color: AppUiTokens.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: AppUiTokens.space8),
                            Text(
                              SettingsMessages.restoreConfirmBody,
                              style: TextStyle(
                                color: AppUiTokens.textSecondary,
                                fontSize: 14,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppUiTokens.space24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back<bool>(result: false),
                        style: AppInteractiveTheme.textButtonStyle(
                          TextButton.styleFrom(
                            foregroundColor: AppUiTokens.textSecondary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppUiTokens.space16,
                              vertical: AppUiTokens.space12,
                            ),
                          ),
                        ),
                        child: const Text(
                          SettingsMessages.restoreConfirmCancel,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: AppUiTokens.space8),
                      FilledButton(
                        onPressed: () => Get.back<bool>(result: true),
                        style: AppInteractiveTheme.filledButtonStyle(
                          FilledButton.styleFrom(
                            backgroundColor: ColorName.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppUiTokens.space24,
                              vertical: AppUiTokens.space12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppUiTokens.radiusSm,
                              ),
                            ),
                          ),
                        ),
                        child: const Text(
                          SettingsMessages.restoreConfirmProceed,
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.42),
    );

    return result ?? false;
  }
}

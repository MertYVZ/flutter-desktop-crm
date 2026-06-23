import 'package:Ok/feature/customers/controllers/customer_detail_controller.dart';
import 'package:Ok/feature/customers/models/customer_contact.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/widgets/panel/panel_text_field.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

Future<void> showCustomerContactFormDialog({
  required CustomerDetailController controller,
  CustomerContactItem? existingContact,
}) async {
  final fullNameController =
      TextEditingController(text: existingContact?.fullName ?? '');
  final titleController =
      TextEditingController(text: existingContact?.title ?? '');
  final emailController =
      TextEditingController(text: existingContact?.email ?? '');
  final phoneController =
      TextEditingController(text: existingContact?.phone ?? '');
  var isPrimary = existingContact?.isPrimary ?? false;

  await Get.dialog<void>(
    Dialog(
      backgroundColor: Colors.transparent,
      insetPadding:
          const EdgeInsets.symmetric(horizontal: AppUiTokens.space24),
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
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      existingContact == null
                          ? 'Yeni Yetkili Ekle'
                          : 'Yetkili Kişiyi Düzenle',
                      style: const TextStyle(
                        color: AppUiTokens.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppUiTokens.space24),
                    PanelTextField(
                      controller: fullNameController,
                      label: 'Ad Soyad',
                    ),
                    const SizedBox(height: AppUiTokens.space16),
                    PanelTextField(
                      controller: titleController,
                      label: 'Ünvan',
                    ),
                    const SizedBox(height: AppUiTokens.space16),
                    PanelTextField(
                      controller: emailController,
                      label: 'Mail',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: AppUiTokens.space16),
                    PanelTextField(
                      controller: phoneController,
                      label: 'Telefon',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: AppUiTokens.space16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: isPrimary,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          side: const BorderSide(
                            color: AppUiTokens.border,
                            width: 1.5,
                          ),
                          fillColor: WidgetStateProperty.resolveWith(
                            (states) {
                              if (states.contains(WidgetState.selected)) {
                                return ColorName.primary;
                              }
                              return AppUiTokens.surface;
                            },
                          ),
                          checkColor: Colors.white,
                          onChanged: (value) {
                            setState(() => isPrimary = value ?? false);
                          },
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => isPrimary = !isPrimary),
                            child: Text(
                              'Ana Yetkili mi?',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color: AppUiTokens.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Obx(() {
                      final error = controller.errorMessage.value;
                      if (error == null) {
                        return const SizedBox.shrink();
                      }

                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppUiTokens.space16,
                        ),
                        child: Text(
                          error,
                          style: const TextStyle(
                            color: ColorName.error,
                            fontSize: 13,
                          ),
                        ),
                      );
                    }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: controller.isSavingContact.value
                              ? null
                              : () => Get.back<void>(),
                          style: AppInteractiveTheme.textButtonStyle(
                            TextButton.styleFrom(
                              foregroundColor: AppUiTokens.textSecondary,
                            ),
                          ),
                          child: const Text('Vazgeç'),
                        ),
                        const SizedBox(width: AppUiTokens.space8),
                        Obx(
                          () => FilledButton(
                            onPressed: controller.isSavingContact.value
                                ? null
                                : () async {
                                    controller.clearMessages();
                                    final success = existingContact == null
                                        ? await controller.createContact(
                                            fullName:
                                                fullNameController.text,
                                            title: titleController.text,
                                            email: emailController.text,
                                            phone: phoneController.text,
                                            isPrimary: isPrimary,
                                          )
                                        : await controller.updateContact(
                                            contactId: existingContact.id,
                                            fullName:
                                                fullNameController.text,
                                            title: titleController.text,
                                            email: emailController.text,
                                            phone: phoneController.text,
                                            isPrimary: isPrimary,
                                          );

                                    if (success) {
                                      Get.back<void>();
                                    }
                                  },
                            style: AppInteractiveTheme.filledButtonStyle(
                              FilledButton.styleFrom(
                                backgroundColor: ColorName.primary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            child: controller.isSavingContact.value
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Kaydet'),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    ),
    barrierDismissible: false,
  );

  fullNameController.dispose();
  titleController.dispose();
  emailController.dispose();
  phoneController.dispose();
}

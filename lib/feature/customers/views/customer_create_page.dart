import 'package:Ok/feature/customers/controllers/customers_controller.dart';
import 'package:Ok/feature/customers/models/customer_status.dart';
import 'package:Ok/feature/customers/models/customer_type.dart';
import 'package:Ok/feature/customers/widgets/customer_form.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/state/base/state/base_state.dart';
import 'package:Ok/product/state/base/view/base_view.dart';
import 'package:Ok/product/widgets/panel/panel_message.dart';
import 'package:Ok/product/widgets/panel/panel_form_page_header.dart';
import 'package:Ok/product/widgets/panel/panel_form_scroll_view.dart';
import 'package:Ok/product/widgets/panel/panel_surface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final class CustomerCreatePage extends StatefulWidget {
  const CustomerCreatePage({super.key});

  @override
  State<CustomerCreatePage> createState() => _CustomerCreatePageState();
}

class _CustomerCreatePageState extends BaseState<CustomerCreatePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _cityController;
  late final TextEditingController _countryController;
  late final TextEditingController _addressController;
  CustomerType? _selectedType;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _cityController = TextEditingController();
    _countryController = TextEditingController(text: 'Türkiye');
    _addressController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<CustomersController>(
      viewModel: Get.find<CustomersController>(),
      onModelReady: (controller) => controller.clearMessages(),
      onPageBuilder: (context, controller) {
        return PanelFormScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PanelFormPageHeader(
                title: 'Yeni Müşteri',
                subtitle: 'Yeni müşteri kaydı oluşturun.',
                onBack: () => Get.offNamed<void>(AppRoutes.customers.value),
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
                    CustomerForm(
                      nameController: _nameController,
                      phoneController: _phoneController,
                      emailController: _emailController,
                      cityController: _cityController,
                      countryController: _countryController,
                      addressController: _addressController,
                      selectedType: _selectedType,
                      selectedStatus: CustomerStatus.active,
                      showStatus: false,
                      onTypeChanged: (value) => setState(() {
                        _selectedType = value;
                      }),
                      onStatusChanged: (_) {},
                    ),
                    const SizedBox(height: AppUiTokens.space24),
                    Obx(
                      () => CustomerFormActions(
                        isSaving: controller.isSaving.value,
                        onSave: controller.isSaving.value
                            ? null
                            : () => _submit(controller),
                        onCancel: controller.isSaving.value
                            ? () {}
                            : () =>
                                Get.offNamed<void>(AppRoutes.customers.value),
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

  Future<void> _submit(CustomersController controller) async {
    final id = await controller.createCustomer(
      name: _nameController.text,
      type: _selectedType,
      phone: _phoneController.text,
      email: _emailController.text,
      city: _cityController.text,
      country: _countryController.text,
      address: _addressController.text,
    );

    if (id != null) {
      Get.offNamed<void>(AppRoutes.customers.value);
    }
  }
}

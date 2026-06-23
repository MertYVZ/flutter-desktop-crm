import 'package:Ok/feature/customers/controllers/customers_controller.dart';
import 'package:Ok/feature/customers/models/customer_status.dart';
import 'package:Ok/feature/customers/models/customer_type.dart';
import 'package:Ok/feature/customers/widgets/customer_form.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/state/base/state/base_state.dart';
import 'package:Ok/product/state/base/view/base_view.dart';
import 'package:Ok/product/utility/constants/customer_messages.dart';
import 'package:Ok/product/widgets/panel/panel_message.dart';
import 'package:Ok/product/widgets/panel/panel_form_scroll_view.dart';
import 'package:Ok/product/widgets/panel/panel_surface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final class CustomerEditPage extends StatefulWidget {
  const CustomerEditPage({super.key});

  @override
  State<CustomerEditPage> createState() => _CustomerEditPageState();
}

class _CustomerEditPageState extends BaseState<CustomerEditPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _cityController;
  late final TextEditingController _countryController;
  late final TextEditingController _addressController;
  CustomerType? _selectedType;
  CustomerStatus _selectedStatus = CustomerStatus.active;
  bool _isFormInitialized = false;

  String get _customerId => Get.parameters['id'] ?? '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _cityController = TextEditingController();
    _countryController = TextEditingController();
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

  void _populateForm(CustomersController controller) {
    final customer = controller.selectedCustomer.value;
    if (customer == null || _isFormInitialized) {
      return;
    }

    _nameController.text = customer.name;
    _phoneController.text = customer.phone ?? '';
    _emailController.text = customer.email ?? '';
    _cityController.text = customer.city ?? '';
    _countryController.text = customer.country ?? '';
    _addressController.text = customer.address ?? '';
    _selectedType = CustomerTypeX.fromValue(customer.type);
    _selectedStatus =
        CustomerStatusX.fromValue(customer.status) ?? CustomerStatus.active;
    _isFormInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<CustomersController>(
      viewModel: Get.find<CustomersController>(),
      onModelReady: (controller) {
        _isFormInitialized = false;
        controller.clearMessages();
        controller.getCustomerById(_customerId).then((loaded) {
          if (!loaded || !mounted) {
            return;
          }

          setState(() {
            _populateForm(controller);
          });
        });
      },
      onPageBuilder: (context, controller) {
        return Obx(() {
          if (controller.isDetailLoading.value ||
              (controller.selectedCustomer.value != null &&
                  !_isFormInitialized)) {
            return const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final customer = controller.selectedCustomer.value;
          if (customer == null) {
            return Center(
              child: Text(
                controller.errorMessage.value ?? CustomerMessages.notFound,
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
                _PageHeader(
                  title: 'Müşteri Düzenle',
                  subtitle: customer.name,
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
                        selectedStatus: _selectedStatus,
                        showStatus: true,
                        onTypeChanged: (value) => setState(() {
                          _selectedType = value;
                        }),
                        onStatusChanged: (value) => setState(() {
                          if (value != null) {
                            _selectedStatus = value;
                          }
                        }),
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
                              : () => Get.offNamed<void>(
                                    AppRoutes.customersDetail
                                        .pathForId(customer.id),
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

  Future<void> _submit(CustomersController controller) async {
    final success = await controller.updateCustomer(
      id: _customerId,
      name: _nameController.text,
      type: _selectedType,
      phone: _phoneController.text,
      email: _emailController.text,
      city: _cityController.text,
      country: _countryController.text,
      address: _addressController.text,
      status: _selectedStatus,
    );

    if (success) {
      Get.offNamed<void>(AppRoutes.customersDetail.pathForId(_customerId));
    }
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppUiTokens.textPrimary,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
        ),
        const SizedBox(height: AppUiTokens.space8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppUiTokens.textSecondary,
              ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../settings/domain/entities/settings_entities.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/bloc/settings_event.dart';

class AddLineModal extends StatefulWidget {
  const AddLineModal({super.key});

  @override
  State<AddLineModal> createState() => _AddLineModalState();
}

class _AddLineModalState extends State<AddLineModal> {
  String? _selectedLineType;
  bool _isLineTypeOpen = false;
  bool _closeLoanManually = false;
  bool _enablePenalty = false;
  bool _keepPaidCustomer = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _interestController = TextEditingController();
  final TextEditingController _billAmountController = TextEditingController();
  final TextEditingController _installController = TextEditingController();
  final TextEditingController _badLoanDaysController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _interestController.dispose();
    _billAmountController.dispose();
    _installController.dispose();
    _badLoanDaysController.dispose();
    super.dispose();
  }

  final List<ExpansionTileController> _upiControllers = [
    ExpansionTileController(),
    ExpansionTileController(),
    ExpansionTileController(),
  ];

  List<String> get _lineTypes => [
    'Daily',
    'Weekly',
    'Monthly',
    'Monthly(Interest)',
    'Enterprise',
    'Auto Finance',
    'Gold Loan',
  ];

  void _showLineTypeDialog() async {
    setState(() {
      _isLineTypeOpen = true;
    });
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Line Type'),
              contentPadding: const EdgeInsets.only(top: 16.0),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _lineTypes.map((type) {
                    return RadioListTile<String>(
                      title: Text(type),
                      value: type,
                      groupValue: _selectedLineType,
                      onChanged: (value) {
                        setDialogState(() {
                          _selectedLineType = value;
                        });
                        setState(() {
                          _selectedLineType = value;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('CANCEL', style: TextStyle(color: Colors.lightBlue)),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK', style: TextStyle(color: Colors.lightBlue)),
                ),
              ],
            );
          },
        );
      },
    );
    if (mounted) {
      setState(() {
        _isLineTypeOpen = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Line'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.xmark),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _buildTextField('Line Name', _nameController),
                  GestureDetector(
                    onTap: _showLineTypeDialog,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: _isLineTypeOpen ? Colors.blue : Colors.grey.shade300, width: _isLineTypeOpen ? 1.5 : 1.0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedLineType ?? 'Line Type',
                            style: TextStyle(fontSize: 16, color: _isLineTypeOpen ? Colors.redAccent : Colors.black87),
                          ),
                          Icon(
                            _isLineTypeOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                            color: _isLineTypeOpen ? Colors.redAccent : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildTextField('Interest Per Hundred', _interestController, isNumber: true),
                  _buildTextField('Bill Amount Per Hundred', _billAmountController, isNumber: true),
                  _buildTextField('No Of Install', _installController, isNumber: true),
                  _buildTextField('Bad Loan Days', _badLoanDaysController, isNumber: true),
                  _buildSwitch('Close Loan Manually', _closeLoanManually, (val) => setState(() => _closeLoanManually = val)),
                  _buildSwitch('Enable Penalty', _enablePenalty, (val) => setState(() => _enablePenalty = val)),
                  _buildSwitch('Keep Paid Customer in Completed Tab?', _keepPaidCustomer, (val) => setState(() => _keepPaidCustomer = val)),
                  _buildUpiExpansionTile('UPI QR Code 1', 0),
                  _buildUpiExpansionTile('UPI QR Code 2', 1),
                  _buildUpiExpansionTile('UPI QR Code 3', 2),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  if (_nameController.text.trim().isEmpty || _selectedLineType == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill Line Name and Type')));
                    return;
                  }
                  final newLine = LineEntity(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: _nameController.text.trim(),
                    type: _selectedLineType!,
                    interestPerHundred: double.tryParse(_interestController.text) ?? 0.0,
                    billAmountPerHundred: double.tryParse(_billAmountController.text) ?? 0.0,
                    noOfInstall: int.tryParse(_installController.text) ?? 0,
                    badLoanDays: int.tryParse(_badLoanDaysController.text) ?? 0,
                    closeLoanManually: _closeLoanManually,
                    enablePenalty: _enablePenalty,
                    keepPaidCustomer: _keepPaidCustomer,
                  );
                  context.read<SettingsBloc>().add(AddLineSubmitted(newLine));
                  Navigator.of(context).pop();
                },
                child: const Text('SAVE'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, {bool isNumber = false}) {
    return Column(
      children: [
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildSwitch(String title, bool value, ValueChanged<bool> onChanged) {
    return Column(
      children: [
        SwitchListTile(
          title: Text(title),
          value: value,
          onChanged: onChanged,
          activeColor: Colors.lightBlue,
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildUpiExpansionTile(String title, int index) {
    return Column(
      children: [
        ExpansionTile(
          controller: _upiControllers[index],
          onExpansionChanged: (expanded) {
            if (expanded) {
              for (int i = 0; i < _upiControllers.length; i++) {
                if (i != index && _upiControllers[i].isExpanded) {
                  _upiControllers[i].collapse();
                }
              }
            }
          },
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        childrenPadding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Stack(
                      children: [
                        const Center(
                          child: Icon(Icons.image, size: 48, color: Colors.grey),
                        ),
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.camera_alt, color: Colors.white),
                                style: IconButton.styleFrom(backgroundColor: Colors.lightBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.delete, color: Colors.white),
                                style: IconButton.styleFrom(backgroundColor: Colors.lightBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Divider(height: 1),
      ],
    );
  }
}

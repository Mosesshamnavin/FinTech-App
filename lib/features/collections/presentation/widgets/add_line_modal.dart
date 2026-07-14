import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../../settings/domain/entities/settings_entities.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/bloc/settings_event.dart';
import '../../../settings/presentation/bloc/settings_state.dart';

class AddLineModal extends StatefulWidget {
  final LineEntity? line;
  const AddLineModal({super.key, this.line});

  @override
  State<AddLineModal> createState() => _AddLineModalState();
}

class _AddLineModalState extends State<AddLineModal> {
  String? _selectedLineTypeId;
  String? _selectedLineTypeName;
  bool _isLineTypeOpen = false;
  bool _closeLoanManually = false;
  bool _enablePenalty = false;
  bool _keepPaidCustomer = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _interestController = TextEditingController();
  final TextEditingController _billAmountController = TextEditingController();
  final TextEditingController _installController = TextEditingController();
  final TextEditingController _badLoanDaysController = TextEditingController();

  final List<String?> _qrImagePaths = [null, null, null];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.line != null) {
      _nameController.text = widget.line!.name;
      _selectedLineTypeId = widget.line!.lineTypeId;
      _selectedLineTypeName = widget.line!.lineTypeName;
      _closeLoanManually = widget.line!.closeLoanManually;
      _enablePenalty = widget.line!.enablePenalty;
      _keepPaidCustomer = widget.line!.keepPaidCustomer;
      _interestController.text = widget.line!.interestPerHundred.toString();
      _billAmountController.text = widget.line!.billAmountPerHundred.toString();
      _installController.text = widget.line!.noOfInstall.toString();
      _badLoanDaysController.text = widget.line!.badLoanDays.toString();
    }
  }

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

  void _showLineTypeDialog(List<LineTypeEntity> lineTypes) async {
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
                  children: lineTypes.map((type) {
                    return RadioListTile<String>(
                      title: Text(type.name),
                      value: type.id,
                      groupValue: _selectedLineTypeId,
                      onChanged: (value) {
                        setDialogState(() {
                          _selectedLineTypeId = value;
                          _selectedLineTypeName = type.name;
                        });
                        setState(() {
                          _selectedLineTypeId = value;
                          _selectedLineTypeName = type.name;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('CANCEL', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
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
    final settingsState = context.read<SettingsBloc>().state;
    List<LineTypeEntity> lineTypes = [];
    if (settingsState is SettingsLoaded) {
      lineTypes = settingsState.lineTypes.where((t) => t.isActive).toList();
    }

    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.line == null ? 'Add Line' : 'Edit Line'),
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
                    onTap: () => _showLineTypeDialog(lineTypes),
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
                            _selectedLineTypeName ?? 'Line Type',
                            style: TextStyle(fontSize: 16, color: _isLineTypeOpen ? Colors.redAccent : Theme.of(context).colorScheme.onSurface),
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
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_nameController.text.trim().isEmpty || _selectedLineTypeId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill Line Name and Type')));
                        return;
                      }
                      final newLine = LineEntity(
                        id: widget.line?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                        name: _nameController.text.trim(),
                        lineTypeId: _selectedLineTypeId!,
                        lineTypeName: _selectedLineTypeName ?? '',
                        interestPerHundred: double.tryParse(_interestController.text) ?? 0.0,
                        billAmountPerHundred: double.tryParse(_billAmountController.text) ?? 0.0,
                        noOfInstall: int.tryParse(_installController.text) ?? 0,
                        badLoanDays: int.tryParse(_badLoanDaysController.text) ?? 0,
                        closeLoanManually: _closeLoanManually,
                        enablePenalty: _enablePenalty,
                        keepPaidCustomer: _keepPaidCustomer,
                      );
                      
                      if (widget.line == null) {
                        context.read<SettingsBloc>().add(AddLineSubmitted(newLine));
                      } else {
                        context.read<SettingsBloc>().add(UpdateLineSubmitted(newLine));
                      }
                      Navigator.of(context).pop();
                    },
                    child: Text(widget.line == null ? 'SAVE' : 'UPDATE'),
                  ),
                  if (widget.line != null) ...[
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () {
                        context.read<SettingsBloc>().add(DeleteLineSubmitted(widget.line!.id));
                        Navigator.of(context).pop();
                      },
                      child: const Text('DELETE', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ],
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
          activeColor: Theme.of(context).colorScheme.primary,
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
                        Center(
                          child: _qrImagePaths[index] != null 
                              ? Image.file(File(_qrImagePaths[index]!), fit: BoxFit.cover)
                              : const Icon(Icons.image, size: 48, color: Colors.grey),
                        ),
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (ctx) => SafeArea(
                                      child: Wrap(
                                        children: [
                                          ListTile(
                                            leading: const Icon(Icons.photo_library),
                                            title: const Text('Choose from Gallery'),
                                            onTap: () {
                                              Navigator.of(ctx).pop();
                                              _pickImage(index, ImageSource.gallery);
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.camera_alt),
                                            title: const Text('Take a Photo'),
                                            onTap: () {
                                              Navigator.of(ctx).pop();
                                              _pickImage(index, ImageSource.camera);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.camera_alt, color: Colors.white),
                                style: IconButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _qrImagePaths[index] = null;
                                  });
                                },
                                icon: const Icon(Icons.delete, color: Colors.white),
                                style: IconButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
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

  Future<void> _pickImage(int index, ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _qrImagePaths[index] = pickedFile.path;
      });
    }
  }
}

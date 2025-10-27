// screens/research_access_screen.dart
import 'package:disease_tracker/models/research_access_model.dart';
import 'package:disease_tracker/providers/controllers/auth_provider.dart';
import 'package:disease_tracker/providers/controllers/current_user_provider.dart';
import 'package:disease_tracker/providers/controllers/research_access/research_access_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

class ResearchAccessScreen extends ConsumerStatefulWidget {
  const ResearchAccessScreen({super.key});

  @override
  ConsumerState<ResearchAccessScreen> createState() =>
      _ResearchAccessScreenState();
}

class _ResearchAccessScreenState extends ConsumerState<ResearchAccessScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool _useDifferentEmail = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _institutionController = TextEditingController();
  final TextEditingController _researchTopicController =
      TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _fullNameController.dispose();
    _institutionController.dispose();
    _researchTopicController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      ref
          .read(researchAccessControllerProvider.notifier)
          .addRequest(
            ResearchAccessRequest(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              fullName: '',
              institution: '',
              researchTopic: '',
              ethicalApprovalPath: result.files.single.path.toString(),
              hasConsent: false,
              userId: '',
              userEmail: '',
              requestDate: DateTime.now(),
            ),
          );
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = ref.read(authControllerProvider);
    if (authState != AuthStatus.authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to submit requests'),
        ),
      );
      return;
    }

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    setState(() => _isSubmitting = true);

    try {
      final request = ResearchAccessRequest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fullName: _fullNameController.text,
        institution: _institutionController.text,
        researchTopic: _researchTopicController.text,
        ethicalApprovalPath:
            ref.read(researchAccessControllerProvider).last.ethicalApprovalPath,
        hasConsent: ref.read(researchAccessControllerProvider).last.hasConsent,
        userId: currentUser.id,
        userEmail:
            _useDifferentEmail ? _emailController.text : currentUser.email,
        requestDate: DateTime.now(),
      );

      ref.read(researchAccessControllerProvider.notifier).addRequest(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request submitted successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final request =
        ref.watch(researchAccessControllerProvider).lastOrNull ??
        ResearchAccessRequest(
          id: '',
          fullName: '',
          institution: '',
          researchTopic: '',
          hasConsent: false,
          userId: '',
          userEmail: currentUser?.email ?? '',
          requestDate: DateTime.now(),
          ethicalApprovalPath: '',
        );

    // Initialize controllers with current values
    if (_fullNameController.text.isEmpty && request.fullName.isNotEmpty) {
      _fullNameController.text = request.fullName;
    }
    if (_institutionController.text.isEmpty && request.institution.isNotEmpty) {
      _institutionController.text = request.institution;
    }
    if (_researchTopicController.text.isEmpty &&
        request.researchTopic.isNotEmpty) {
      _researchTopicController.text = request.researchTopic;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Research Access Request'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator:
                    (value) => value?.isEmpty ?? true ? 'Required' : null,
                onChanged:
                    (value) => ref
                        .read(researchAccessControllerProvider.notifier)
                        .addRequest(request.copyWith(fullName: value)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _institutionController,
                decoration: const InputDecoration(
                  labelText: 'Institution',
                  prefixIcon: Icon(Icons.school),
                ),
                validator:
                    (value) => value?.isEmpty ?? true ? 'Required' : null,
                onChanged:
                    (value) => ref
                        .read(researchAccessControllerProvider.notifier)
                        .addRequest(request.copyWith(institution: value)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _researchTopicController,
                decoration: const InputDecoration(
                  labelText: 'Research Topic',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator:
                    (value) => value?.isEmpty ?? true ? 'Required' : null,
                onChanged:
                    (value) => ref
                        .read(researchAccessControllerProvider.notifier)
                        .addRequest(request.copyWith(researchTopic: value)),
              ),
              const SizedBox(height: 16),
              _buildFileUpload(request.ethicalApprovalPath),
              const SizedBox(height: 16),
              _buildEmailSection(currentUser?.email ?? ''),
              const SizedBox(height: 16),
              _buildConsentCheckbox(request.hasConsent),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRequest,
                child:
                    _isSubmitting
                        ? const CircularProgressIndicator()
                        : const Text('Submit Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileUpload(String? filePath) {
    return Column(
      children: [
        OutlinedButton.icon(
          icon: const Icon(Icons.upload_file),
          label: const Text('Upload Ethical Approval (PDF)'),
          onPressed: _pickFile,
        ),
        if (filePath != null) ...[
          const SizedBox(height: 8),
          Text(
            'Selected: ${filePath.split('/').last}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }

  Widget _buildEmailSection(String userEmail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Contact Email'),
        if (!_useDifferentEmail) ...[
          Text(userEmail),
          TextButton(
            onPressed: () => setState(() => _useDifferentEmail = true),
            child: const Text('Use different email'),
          ),
        ] else ...[
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              hintText: 'Enter your email',
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Required';
              if (!value.contains('@') || !value.contains('.')) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          TextButton(
            onPressed: () => setState(() => _useDifferentEmail = false),
            child: const Text('Use my account email'),
          ),
        ],
      ],
    );
  }

  Widget _buildConsentCheckbox(bool hasConsent) {
    return Row(
      children: [
        Checkbox(
          value: hasConsent,
          onChanged:
              (value) => ref
                  .read(researchAccessControllerProvider.notifier)
                  .addRequest(
                    ref
                        .read(researchAccessControllerProvider)
                        .last
                        .copyWith(hasConsent: value ?? false),
                  ),
        ),
        const Expanded(
          child: Text(
            'I understand this data is anonymized and for research purposes only',
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/features/profile/controllers/profile_controller.dart';
import 'package:flutter_boilerplate/features/profile/data/models/country.dart';
import 'package:flutter_boilerplate/features/profile/data/repository/profile_repository.dart';
import 'package:flutter_boilerplate/shared/widgets/app_button.dart';
import 'package:flutter_boilerplate/shared/widgets/app_text_field.dart';
import 'package:flutter_boilerplate/shared/widgets/custom_app_bar.dart';
import 'package:flutter_boilerplate/shared/widgets/modern_notification.dart';
import 'package:flutter_boilerplate/shared/widgets/phone_field.dart';

/// Page d'édition du profil utilisateur.
///
/// Permet à l'utilisateur de modifier ses informations personnelles :
/// - Prénom et nom
/// - Email
/// - Téléphone
/// - Adresse, ville et pays
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneFieldKey = PhoneFieldStateKey();

  final ProfileController _profileController = Get.find<ProfileController>();
  final ProfileRepository _profileRepository = Get.find<ProfileRepository>();

  bool _isLoading = false;
  bool _isLoadingCountries = false;
  String? _errorMessage;
  List<Country> _countries = [];
  Country? _selectedCountry;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadCountries();
  }

  /// Charge les données de l'utilisateur dans les champs du formulaire.
  void _loadUserData() {
    final user = _profileController.user;
    if (user != null) {
      _firstNameController.text = user.firstname;
      _lastNameController.text = user.lastname;
      _emailController.text = user.email ?? '';

      // Pour les utilisateurs Google, laisser le champ téléphone vide
      // pour leur permettre de saisir leur numéro
      if (user.isGoogleUser) {
        _phoneController.text = '';
      } else {
        // Extraire le numéro de téléphone sans le code pays
        final phone = user.phone.replaceAll(RegExp(r'^\+?\d{1,3}'), '');
        _phoneController.text = phone;
      }

      _addressController.text = user.address ?? '';
      _cityController.text = user.city ?? '';
    }
  }

  /// Charge la liste des pays depuis l'API.
  Future<void> _loadCountries() async {
    setState(() {
      _isLoadingCountries = true;
      _errorMessage = null;
    });

    try {
      final response = await _profileRepository.getCountries();

      if (response.success && response.data.isNotEmpty) {
        setState(() {
          _countries = response.data;
          _isLoadingCountries = false;
        });

        // Sélectionner le pays de l'utilisateur si disponible
        final user = _profileController.user;
        if (user?.countryId != null && _countries.isNotEmpty) {
          try {
            final userCountry = _countries.firstWhere(
              (country) => country.id == user!.countryId,
            );
            setState(() {
              _selectedCountry = userCountry;
            });
          } catch (e) {
            // Le pays de l'utilisateur n'est pas dans la liste
          }
        }
      } else {
        setState(() {
          _isLoadingCountries = false;
          _errorMessage = 'Impossible de charger la liste des pays';
        });
        if (mounted) {
          ModernNotification.showError(
            context,
            'Impossible de charger la liste des pays',
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingCountries = false;
        _errorMessage = 'Erreur lors du chargement des pays: ${e.toString()}';
      });
      if (mounted) {
        ModernNotification.showError(
          context,
          'Erreur lors du chargement des pays',
        );
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  /// Valide et soumet le formulaire de modification du profil.
  Future<void> _handleSave() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Construire le numéro de téléphone complet
      final countryCode =
          _phoneFieldKey.currentState?.getCountryCode() ?? '228';
      final phoneNumber = _phoneController.text.trim();
      final fullPhone = phoneNumber.startsWith('+')
          ? phoneNumber
          : '+$countryCode$phoneNumber';

      // Appeler l'API pour mettre à jour le profil
      final response = await _profileRepository.updateProfile(
        firstname: _firstNameController.text.trim(),
        lastname: _lastNameController.text.trim(),
        email: _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : null,
        phone: fullPhone,
        address: _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : null,
        city: _cityController.text.trim().isNotEmpty
            ? _cityController.text.trim()
            : null,
        countryId: _selectedCountry?.id,
      );

      if (response.success && response.data != null) {
        // Mettre à jour le profil local immédiatement avec la réponse API.
        _profileController.setUser(response.data!.user);

        // Tenter un rechargement depuis l'API pour rester synchronisé.
        // On ne bloque pas le succès UI si ce refresh échoue.
        await _profileController.refreshProfile();

        if (mounted) {
          Get.back();
          ModernNotification.showSuccess(
            context,
            'profile_updated_successfully'.tr,
            duration: const Duration(seconds: 2),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          // Afficher les erreurs de validation spécifiques si disponibles
          if (response.hasValidationErrors && response.errors != null) {
            final errorMessages = <String>[];

            // Extraire tous les messages d'erreur des différents champs
            response.errors!.forEach((key, value) {
              if (value is List) {
                for (var error in value) {
                  if (error != null && error.toString().isNotEmpty) {
                    errorMessages.add(error.toString());
                  }
                }
              } else if (value is String && value.isNotEmpty) {
                errorMessages.add(value);
              }
            });

            // Afficher les messages d'erreur détaillés
            if (errorMessages.isNotEmpty) {
              ModernNotification.showError(
                context,
                errorMessages.join('\n'),
                duration: const Duration(seconds: 4),
              );
            } else {
              // Fallback au message générique si aucun message détaillé n'est trouvé
              ModernNotification.showError(
                context,
                response.message.isNotEmpty
                    ? response.message
                    : 'update_profile_error'.tr,
              );
            }
          } else {
            ModernNotification.showError(
              context,
              response.message.isNotEmpty
                  ? response.message
                  : 'update_profile_error'.tr,
            );
          }
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la mise à jour du profil';
        _isLoading = false;
      });
      if (mounted) {
        ModernNotification.showError(
          context,
          _errorMessage ?? 'update_profile_error'.tr,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(title: 'edit_profile'.tr, centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Champ prénom
                AppTextField(
                  controller: _firstNameController,
                  label: 'first_name'.tr,
                  prefixIcon: Icons.person_outline,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'first_name_required'.tr;
                    }
                    if (value.trim().length < 2) {
                      return 'first_name_min_length'.tr;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Champ nom
                AppTextField(
                  controller: _lastNameController,
                  label: 'last_name'.tr,
                  prefixIcon: Icons.person_outline,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'last_name_required'.tr;
                    }
                    if (value.trim().length < 2) {
                      return 'last_name_min_length'.tr;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Champ email
                AppTextField(
                  controller: _emailController,
                  label: 'email'.tr,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      // Regex acceptant les TLD modernes
                      final emailRegex = RegExp(
                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                      );
                      if (!emailRegex.hasMatch(value.trim())) {
                        return 'email_invalid'.tr;
                      }
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Champ téléphone
                PhoneField(
                  key: _phoneFieldKey,
                  controller: _phoneController,
                  label: 'phone'.tr,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'phone_required'.tr;
                    }
                    final phoneRegex = RegExp(r'^[0-9]{8,15}$');
                    if (!phoneRegex.hasMatch(value.trim())) {
                      return 'phone_invalid'.tr;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Champ adresse
                AppTextField(
                  controller: _addressController,
                  label: 'address'.tr,
                  prefixIcon: Icons.location_on_outlined,
                  keyboardType: TextInputType.streetAddress,
                  textInputAction: TextInputAction.next,
                  maxLines: 2,
                ),

                const SizedBox(height: 16),

                // Champ ville
                AppTextField(
                  controller: _cityController,
                  label: 'city'.tr,
                  prefixIcon: Icons.location_city_outlined,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 16),

                // Sélecteur de pays
                DropdownButtonFormField<Country>(
                  initialValue: _selectedCountry,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'country'.tr,
                    prefixIcon: Icon(
                      Icons.public_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  items: _isLoadingCountries
                      ? [
                          DropdownMenuItem<Country>(
                            value: null,
                            child: Text(
                              'loading'.tr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ]
                      : _countries.map((country) {
                          return DropdownMenuItem<Country>(
                            value: country,
                            child: Text(
                              country.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                  onChanged: _isLoadingCountries
                      ? null
                      : (Country? country) {
                          setState(() {
                            _selectedCountry = country;
                          });
                        },
                  validator: (value) {
                    // Le pays est optionnel selon l'API
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Bouton de sauvegarde
                AppButton(
                  label: 'save'.tr,
                  onPressed: _isLoading ? null : _handleSave,
                  isLoading: _isLoading,
                  width: -1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

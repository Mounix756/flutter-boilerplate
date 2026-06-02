import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/core/theme/app_colors.dart';

/// Modèle pour un indicatif pays.
class CountryCode {
  final String code;
  final String dialCode;
  final String name;
  final String flag;

  const CountryCode({
    required this.code,
    required this.dialCode,
    required this.name,
    required this.flag,
  });
}

/// Liste des indicatifs pays courants.
class CountryCodes {
  static const List<CountryCode> codes = [
    // Pays africains francophones (priorité)
    CountryCode(code: 'TG', dialCode: '+228', name: 'Togo', flag: '🇹🇬'),
    CountryCode(code: 'BJ', dialCode: '+229', name: 'Bénin', flag: '🇧🇯'),
    CountryCode(
      code: 'BF',
      dialCode: '+226',
      name: 'Burkina Faso',
      flag: '🇧🇫',
    ),
    CountryCode(
      code: 'CI',
      dialCode: '+225',
      name: "Côte d'Ivoire",
      flag: '🇨🇮',
    ),
    CountryCode(code: 'SN', dialCode: '+221', name: 'Sénégal', flag: '🇸🇳'),
    CountryCode(code: 'ML', dialCode: '+223', name: 'Mali', flag: '🇲🇱'),
    CountryCode(code: 'NE', dialCode: '+227', name: 'Niger', flag: '🇳🇪'),
    CountryCode(code: 'CM', dialCode: '+237', name: 'Cameroun', flag: '🇨🇲'),
    CountryCode(code: 'CD', dialCode: '+243', name: 'RD Congo', flag: '🇨🇩'),
    CountryCode(code: 'CG', dialCode: '+242', name: 'Congo', flag: '🇨🇬'),
    CountryCode(code: 'GA', dialCode: '+241', name: 'Gabon', flag: '🇬🇦'),
    CountryCode(code: 'TD', dialCode: '+235', name: 'Tchad', flag: '🇹🇩'),
    CountryCode(
      code: 'CF',
      dialCode: '+236',
      name: 'Centrafrique',
      flag: '🇨🇫',
    ),
    CountryCode(code: 'GN', dialCode: '+224', name: 'Guinée', flag: '🇬🇳'),
    CountryCode(
      code: 'GW',
      dialCode: '+245',
      name: 'Guinée-Bissau',
      flag: '🇬🇼',
    ),
    CountryCode(
      code: 'GQ',
      dialCode: '+240',
      name: 'Guinée équatoriale',
      flag: '🇬🇶',
    ),
    CountryCode(code: 'MG', dialCode: '+261', name: 'Madagascar', flag: '🇲🇬'),
    CountryCode(code: 'MU', dialCode: '+230', name: 'Maurice', flag: '🇲🇺'),
    CountryCode(code: 'SC', dialCode: '+248', name: 'Seychelles', flag: '🇸🇨'),
    CountryCode(code: 'KM', dialCode: '+269', name: 'Comores', flag: '🇰🇲'),
    CountryCode(code: 'DJ', dialCode: '+253', name: 'Djibouti', flag: '🇩🇯'),
    CountryCode(code: 'MR', dialCode: '+222', name: 'Mauritanie', flag: '🇲🇷'),
    CountryCode(code: 'TN', dialCode: '+216', name: 'Tunisie', flag: '🇹🇳'),
    CountryCode(code: 'DZ', dialCode: '+213', name: 'Algérie', flag: '🇩🇿'),
    CountryCode(code: 'MA', dialCode: '+212', name: 'Maroc', flag: '🇲🇦'),
    CountryCode(code: 'RW', dialCode: '+250', name: 'Rwanda', flag: '🇷🇼'),
    CountryCode(code: 'BI', dialCode: '+257', name: 'Burundi', flag: '🇧🇮'),

    // Autres pays africains
    CountryCode(code: 'GH', dialCode: '+233', name: 'Ghana', flag: '🇬🇭'),
    CountryCode(code: 'NG', dialCode: '+234', name: 'Nigeria', flag: '🇳🇬'),
    CountryCode(code: 'KE', dialCode: '+254', name: 'Kenya', flag: '🇰🇪'),
    CountryCode(code: 'TZ', dialCode: '+255', name: 'Tanzanie', flag: '🇹🇿'),
    CountryCode(code: 'UG', dialCode: '+256', name: 'Ouganda', flag: '🇺🇬'),
    CountryCode(code: 'ET', dialCode: '+251', name: 'Éthiopie', flag: '🇪🇹'),
    CountryCode(
      code: 'ZA',
      dialCode: '+27',
      name: 'Afrique du Sud',
      flag: '🇿🇦',
    ),
    CountryCode(code: 'EG', dialCode: '+20', name: 'Égypte', flag: '🇪🇬'),
    CountryCode(code: 'AO', dialCode: '+244', name: 'Angola', flag: '🇦🇴'),
    CountryCode(code: 'MZ', dialCode: '+258', name: 'Mozambique', flag: '🇲🇿'),
    CountryCode(code: 'ZM', dialCode: '+260', name: 'Zambie', flag: '🇿🇲'),
    CountryCode(code: 'ZW', dialCode: '+263', name: 'Zimbabwe', flag: '🇿🇼'),
    CountryCode(code: 'BW', dialCode: '+267', name: 'Botswana', flag: '🇧🇼'),
    CountryCode(code: 'NA', dialCode: '+264', name: 'Namibie', flag: '🇳🇦'),

    // Pays européens et autres
    CountryCode(code: 'FR', dialCode: '+33', name: 'France', flag: '🇫🇷'),
    CountryCode(code: 'BE', dialCode: '+32', name: 'Belgique', flag: '🇧🇪'),
    CountryCode(code: 'CH', dialCode: '+41', name: 'Suisse', flag: '🇨🇭'),
    CountryCode(code: 'GB', dialCode: '+44', name: 'UK', flag: '🇬🇧'),
    CountryCode(code: 'DE', dialCode: '+49', name: 'Allemagne', flag: '🇩🇪'),
    CountryCode(code: 'IT', dialCode: '+39', name: 'Italie', flag: '🇮🇹'),
    CountryCode(code: 'ES', dialCode: '+34', name: 'Espagne', flag: '🇪🇸'),
    CountryCode(code: 'US', dialCode: '+1', name: 'USA', flag: '🇺🇸'),
    CountryCode(code: 'CA', dialCode: '+1', name: 'Canada', flag: '🇨🇦'),
  ];

  static CountryCode getDefault() => codes.first; // Togo par défaut
}

/// Champ de saisie téléphone avec sélection d'indicatif pays.
class PhoneField extends StatefulWidget {
  final TextEditingController controller;
  final String? label;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final bool enabled;
  final FocusNode? focusNode;

  const PhoneField({
    super.key,
    required this.controller,
    this.label,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
    this.enabled = true,
    this.focusNode,
  });

  @override
  State<PhoneField> createState() => _PhoneFieldState();
}

/// Type alias pour la clé globale du PhoneField.
/// Permet d'accéder à l'état du PhoneField et récupérer le country code.
typedef PhoneFieldStateKey = GlobalKey<_PhoneFieldState>;

class _PhoneFieldState extends State<PhoneField> {
  late CountryCode selectedCountry;

  @override
  void initState() {
    super.initState();
    selectedCountry = CountryCodes.getDefault();
  }

  /// Retourne le code pays actuellement sélectionné.
  CountryCode getSelectedCountry() => selectedCountry;

  /// Retourne l'indicatif pays (sans le +).
  String getCountryCode() => selectedCountry.dialCode.replaceAll('+', '');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Label
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.label!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDarkMode
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

        // Champ avec indicatif
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDarkMode
                  ? AppColors.textSecondaryDark.withAlpha(51)
                  : AppColors.textSecondaryLight.withAlpha(51),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Sélecteur d'indicatif
              InkWell(
                onTap: widget.enabled
                    ? () => _showCountryPicker(context, selectedCountry, (
                        country,
                      ) {
                        setState(() {
                          selectedCountry = country;
                        });
                      })
                    : null,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: isDarkMode
                            ? AppColors.textSecondaryDark.withAlpha(51)
                            : AppColors.textSecondaryLight.withAlpha(51),
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedCountry.flag,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        selectedCountry.dialCode,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDarkMode
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down,
                        color: isDarkMode
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              // Champ de saisie du numéro
              Expanded(
                child: TextFormField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  enabled: widget.enabled,
                  keyboardType: TextInputType.phone,
                  textInputAction: widget.textInputAction,
                  onFieldSubmitted: widget.onFieldSubmitted,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isDarkMode
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                  decoration: InputDecoration(
                    hintText: '12345678',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: isDarkMode
                          ? AppColors.textSecondaryDark.withAlpha(128)
                          : AppColors.textSecondaryLight.withAlpha(128),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    isDense: true,
                  ),
                  validator: widget.validator,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Affiche le sélecteur de pays.
  void _showCountryPicker(
    BuildContext context,
    CountryCode currentCountry,
    Function(CountryCode) onCountrySelected,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: false,
      isDismissible: true,
      useSafeArea: true,
      builder: (context) => PopScope(
        canPop: true,
        child: _CountryPickerSheet(
          currentCountry: currentCountry,
          onCountrySelected: (country) {
            onCountrySelected(country);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

/// Bottom sheet pour sélectionner un pays avec recherche.
class _CountryPickerSheet extends StatefulWidget {
  final CountryCode currentCountry;
  final Function(CountryCode) onCountrySelected;

  const _CountryPickerSheet({
    required this.currentCountry,
    required this.onCountrySelected,
  });

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<CountryCode> _filteredCountries = CountryCodes.codes;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterCountries);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterCountries);
    _searchController.dispose();
    super.dispose();
  }

  void _filterCountries() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = CountryCodes.codes;
      } else {
        _filteredCountries = CountryCodes.codes.where((country) {
          return country.name.toLowerCase().contains(query) ||
              country.dialCode.contains(query) ||
              country.code.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Container(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.8),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColors.textSecondaryDark.withAlpha(128)
                    : AppColors.textSecondaryLight.withAlpha(128),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Titre
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(
                'select_country'.tr,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ),

            // Champ de recherche
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: TextField(
                controller: _searchController,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: 'search_country'.tr,
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDarkMode
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _searchController,
                    builder: (context, value, child) {
                      return value.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: isDarkMode
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : const SizedBox.shrink();
                    },
                  ),
                  filled: true,
                  fillColor: isDarkMode
                      ? AppColors.surfaceDark
                      : AppColors.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDarkMode
                          ? AppColors.textSecondaryDark.withAlpha(51)
                          : AppColors.textSecondaryLight.withAlpha(51),
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDarkMode
                          ? AppColors.textSecondaryDark.withAlpha(51)
                          : AppColors.textSecondaryLight.withAlpha(51),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDarkMode
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ),

            // Liste des pays filtrés
            Flexible(
              child: _filteredCountries.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'no_country_found'.tr,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDarkMode
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredCountries.length,
                      itemBuilder: (context, index) {
                        final country = _filteredCountries[index];
                        final isSelected =
                            country.code == widget.currentCountry.code;

                        return InkWell(
                          onTap: () {
                            widget.onCountrySelected(country);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary.withAlpha(26)
                                  : Colors.transparent,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  country.flag,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        country.name,
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w500,
                                              color: isDarkMode
                                                  ? AppColors.textPrimaryDark
                                                  : AppColors.textPrimaryLight,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        country.dialCode,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: isDarkMode
                                                  ? AppColors.textSecondaryDark
                                                  : AppColors
                                                        .textSecondaryLight,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: theme.colorScheme.primary,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Espacement en bas
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'constant/app_colors.dart';

class CrmScreen extends StatefulWidget {
  const CrmScreen({super.key});

  @override
  State<CrmScreen> createState() => _CrmScreenState();
}

class _CrmScreenState extends State<CrmScreen> {
  @override
  Widget build(BuildContext context) {
    double currWidht = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      drawer: currWidht < 750 ?
          Drawer()
          :SizedBox(),
    );
  }
}

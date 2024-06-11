import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:gas_track/helpers/extentions/context_ext.dart';
import 'package:sizer/sizer.dart';


class VisaRecieptsImgs extends StatefulWidget {
  const VisaRecieptsImgs({super.key});

  @override
  State<VisaRecieptsImgs> createState() => _VisaRecieptsImgsState();
}

class _VisaRecieptsImgsState extends State<VisaRecieptsImgs> {
  @override
  Widget build(BuildContext context) {
    final visaRecipts = context.paymentsProvider.getVisaReciptsImg;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      padding: EdgeInsets.all(2.h),
      physics: const ClampingScrollPhysics(),
      children: [
        ...visaRecipts
            .map((e) => GestureDetector(
                  onLongPress: () {
                    context.dialogBuilder.showDeleteImgConfrimation(false, e);
                  },
                  child: Container(
                    height: 20.h,
                    width: 20.w,
                    margin: EdgeInsets.all(5.h),
                    child: Image.file(File(e)),
                  ),
                ))
            .toList(),
        InkWell(
          onTap: () async {
            List<String> pictures;
            try {
              pictures = await CunningDocumentScanner.getPictures() ?? [];
              if (!context.mounted) return;
              context.paymentsProvider.addVisaRecipets(pictures);
            } catch (exception) {
              if (context.mounted) {
                context.dialogBuilder.showSnackBar(exception.toString());
              }
            }
          },
          child: DottedBorder(
            color: Colors.grey[400]!,
            dashPattern: const [8, 4],
            child: Center(
              child: Icon(
                Icons.add,
                size: 5.h,
                color: Colors.grey,
              ),
            ),
          ),
        )
      ],
    );
  }
}

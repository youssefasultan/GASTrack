import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:gas_track/providers/payments_provider.dart';
import 'package:provider/provider.dart';

import '../../../helpers/view/dialog/dialog_builder.dart';

class VisaRecieptsImgs extends StatefulWidget {
  const VisaRecieptsImgs({super.key});

  @override
  State<VisaRecieptsImgs> createState() => _VisaRecieptsImgsState();
}

class _VisaRecieptsImgsState extends State<VisaRecieptsImgs> {
  @override
  Widget build(BuildContext context) {
    final payment = Provider.of<PaymentsProvider>(context);
    final visaRecipts = payment.getVisaReciptsImg;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      padding: const EdgeInsets.all(10.0),
      physics: const ClampingScrollPhysics(),
      children: [
        ...visaRecipts
            .map((e) => GestureDetector(
                  onLongPress: () {
                    DialogBuilder(context).showDeleteImgConfrimation(false, e);
                  },
                  child: Container(
                    height: 30.0,
                    width: 30.0,
                    margin: const EdgeInsets.all(5.0),
                    child: Image.file(File(e)),
                  ),
                ))
            .toList(),
        InkWell(
          onTap: () async {
            List<String> pictures;
            try {
              pictures = await CunningDocumentScanner.getPictures() ?? [];
              if (!mounted) return;
              payment.addVisaRecipets(pictures);
            } catch (exception) {
              DialogBuilder(context).showSnackBar(exception.toString());
            }
          },
          child: DottedBorder(
            color: Colors.grey[400]!,
            dashPattern: const [8, 4],
            child: const Center(
              child: Icon(
                Icons.add,
                size: 30.0,
                color: Colors.grey,
              ),
            ),
          ),
        )
      ],
    );
  }
}

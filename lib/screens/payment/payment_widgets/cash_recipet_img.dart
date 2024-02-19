import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:gas_track/helpers/view/dialog/dialog_builder.dart';
import 'package:gas_track/providers/payments_provider.dart';
import 'package:provider/provider.dart';

class CashRecipetImg extends StatefulWidget {
  const CashRecipetImg({super.key});

  @override
  State<CashRecipetImg> createState() => _CashRecipetImgState();
}

class _CashRecipetImgState extends State<CashRecipetImg> {
  @override
  Widget build(BuildContext context) {
    final payment = Provider.of<PaymentsProvider>(context);

    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.3,
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: payment.getCashRecipetImg.isEmpty
          ? InkWell(
              onTap: () async {
                List<String> pictures;
                try {
                  pictures =
                      await CunningDocumentScanner.getPictures(false) ?? [];
                  if (!mounted) return;
                  if(pictures.isNotEmpty) {
                    payment.setCashRecipetImg(pictures[0]);
                  }
                  
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
                    size: 50.0,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          : GestureDetector(
              onLongPress: () {
                DialogBuilder(context).showDeleteImgConfrimation(true, '');
              },
              child: Image.file(File(payment.getCashRecipetImg)),
            ),
    );
  }
}

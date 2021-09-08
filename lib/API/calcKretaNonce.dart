import 'dart:convert';
import 'package:novynaplo/data/models/student.dart';
import 'package:crypto/crypto.dart';

/*
Tisztelt E-kréta!

Remélem olvassák ezt a kis üzenetet, ha már a leveleimet nem…

Nem tudom, hogy önök szándékosan keserítik/nehezítik meg az alternatív kliens fejlesztők életét, de a módszerek melyeket bevetnek, még egy kezdő 15 éves programozót (pl.: engem) sem képesek visszatartani a folytatástól, viszont egy levél, melyben a „NEM” szó található már képes lenne. Tény, hogy vannak dolgok melyeket nem ideális módon önöktől kérve szerzünk meg, mint pl. a lentebb található encoder kulcs, api kulcsok vagy esetleg a client_id, de, hogyan szerezhetnénk meg ezeket a „titkokat” „nem sértő módon”, ha nem válaszolnak a leveleinkre?

A lényeg az, hogy az alábbi kulcs se ideálisan önöktől lett elkérve, amennyiben ez önöket sérti vagy szeretnének megállapodás alapján „publikus kulcsot” bevezetni, legyenek szívesek írjanak egy levelet a novysoftware@gmail.com -ra.

Köszönettel,
Novotny Levente (Novy)
A Novy Napló fejlesztője
*/

var encoderKey = utf8.encode("5Kmpmgd5fJ");

String calculateKretaNonceKey(Student userDetails, String nonce) {
  String toBeEncoded = userDetails.username.toLowerCase() +
      userDetails.school.toLowerCase() +
      nonce;
  var toBeEncodedUtf = utf8.encode(toBeEncoded);
  var hmac = Hmac(sha512, encoderKey);
  var digest = hmac.convert(toBeEncodedUtf);

  return base64.encode(digest.bytes);
}

# Skladišta podataka - projekat

## Kako pokrenuti projekat?

1. Klonirati repozitorij lokalno.
2. Uz pomoć alata za pregled baze podataka (npr. DB Browser) otvoriti već pripremljeni dwh.db file koji se nalazi na lokaciji: sqlite_baza -> dwh.db.
3. Probati izvršiti pripremljene upite nad DWH bazom koji se nalaze na lokaciji: komande -> upiti.sql. Oni su razdvojeni komentarima koji ih objašnjavaju.
4. dokument_projekta.pdf file sadrži detaljna uputstva o strukturi, izgledu i namjeni samog projekta.
5. Ukoliko želite kreirati novu DWH bazu iste strukture i popunjenosti podacima iz već pripremljene produkcijske baze naziva production.db, možete iskoristiti komande sa lokacije: komande -> kreiranje_dwh.sql i izvršit ih unutar sqlite3 aplikacije koja se nalazi na lokaciji: sqlite_baza -> sqlite3.exe. Prethodno je potrebno otvoriti postojeći dwh.db ili kreirati novi komandom tipa: .open dwh2.db unutar sqlite3 aplikacije.

**NAPOMENA:** DWH je skraćenica od izraza: "Data warehouse", prevoda: "Skladište podataka".

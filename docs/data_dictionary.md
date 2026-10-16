# Data Dictionary – `loans`

Clean table of **completed** Lending Club loans (2007–2018).
Available as `data/processed/loans_clean.parquet` and as the `loans` table in PostgreSQL.

- **Rows:** 1,347,698 (one row per loan)
- **Columns:** 30
- **Source:** [Lending Club Loan Data – Kaggle](https://www.kaggle.com/datasets/wordsforthewise/lending-club)

**Column types**
- **Origination:** known when the loan was issued – safe to use for analysis and modeling
- **Outcome:** known only after the loan ended – use for loss analysis only, **never as model inputs** (data leakage)
- **Derived:** created during cleaning

## Identifier and dates

| Column | SQL type | Type | Description |
| --- | --- | --- | --- |
| `id` | BIGINT | Origination | Unique Lending Club loan id (primary key) |
| `issue_date` | DATE | Derived | Month the loan was issued, stored as the first day of the month (e.g. 2015-12-01) |
| `issue_year` | SMALLINT | Derived | Year of `issue_date` (2007–2018) |
| `issue_quarter` | VARCHAR | Derived | Quarter of `issue_date`, e.g. `2015Q4` – used for vintage analysis |

## Loan

| Column | SQL type | Type | Description |
| --- | --- | --- | --- |
| `loan_amnt` | NUMERIC | Origination | Loan amount applied for, USD (500 – 40,000) |
| `term_months` | SMALLINT | Derived | Loan term in months: 36 or 60 |
| `int_rate` | NUMERIC | Origination | Annual interest rate, percent (e.g. 13.56) |
| `installment` | NUMERIC | Origination | Monthly payment owed by the borrower, USD |
| `grade` | CHAR(1) | Origination | Lending Club risk grade, A (lowest risk) to G (highest risk) |
| `sub_grade` | VARCHAR | Origination | Finer risk grade, A1 to G5 |
| `purpose` | VARCHAR | Origination | Purpose stated by the borrower, e.g. `debt_consolidation`, `credit_card`, `small_business` |

## Borrower

| Column | SQL type | Type | Description |
| --- | --- | --- | --- |
| `emp_length` | VARCHAR | Origination | Employment length as text: `< 1 year`, `1 year` … `10+ years`, or `Unknown` (not reported) |
| `emp_length_years` | SMALLINT | Derived | Employment length as a number, 0–10 (`< 1 year` = 0, `10+ years` = 10). NULL when `Unknown` |
| `home_ownership` | VARCHAR | Origination | `RENT`, `OWN`, `MORTGAGE` or `OTHER` (ANY / NONE / OTHER merged) |
| `annual_inc` | NUMERIC | Origination | Self-reported annual income, USD (≥ 1,000 after cleaning) |
| `verification_status` | VARCHAR | Origination | Whether income was verified: `Not Verified`, `Source Verified`, `Verified` |
| `addr_state` | CHAR(2) | Origination | US state of the borrower, two-letter code |

## Credit history (at origination)

| Column | SQL type | Type | Description |
| --- | --- | --- | --- |
| `dti` | NUMERIC | Origination | Debt-to-income ratio, percent: monthly debt payments (excluding mortgage and this loan) divided by monthly income. NULL if invalid (< 0 or > 100) |
| `fico_range_low` | SMALLINT | Origination | Lower bound of the borrower's FICO credit score range |
| `fico_range_high` | SMALLINT | Origination | Upper bound of the borrower's FICO credit score range |
| `fico_avg` | NUMERIC | Derived | Midpoint of the FICO range: (low + high) / 2 |
| `revol_util` | NUMERIC | Origination | Revolving credit utilization, percent: credit card balance relative to credit limit. NULL if > 150 |
| `open_acc` | SMALLINT | Origination | Number of open credit lines |
| `delinq_2yrs` | SMALLINT | Origination | Number of 30+ days past-due incidents in the last 2 years |
| `inq_last_6mths` | SMALLINT | Origination | Number of credit inquiries in the last 6 months |

## Outcome (post-origination – do not use as model inputs)

| Column | SQL type | Type | Description |
| --- | --- | --- | --- |
| `loan_status` | VARCHAR | Outcome | Final status: `Fully Paid`, `Charged Off`, `Default`, or the "Does not meet the credit policy" variants |
| `is_default` | SMALLINT | Derived | Target variable: 1 = Charged Off / Default, 0 = Fully Paid |
| `total_pymnt` | NUMERIC | Outcome | Total amount received from the borrower, USD (principal + interest + fees + recoveries) |
| `recoveries` | NUMERIC | Outcome | Amount recovered after the loan was charged off, USD |
| `net_loss` | NUMERIC | Derived | Cash loss: `loan_amnt − total_pymnt` for defaulted loans (minimum 0), 0 for paid loans |

## Missing values

| Column | Missing | Reason |
| --- | --- | --- |
| `emp_length_years` | 78,178 | Employment length not reported (`emp_length` = `Unknown`) |
| `revol_util` | 912 | Missing in source data or implausible value (> 150) removed |
| `dti` | 516 | Missing in source data or invalid value (< 0 or > 100) removed |
| `open_acc`, `delinq_2yrs`, `inq_last_6mths` | 25–26 | Missing in source data (older loans) |

Missing values are intentionally **not imputed** in the clean table. Imputation is done in the model notebook using training data only.
---

# Veri Sözlüğü (Türkçe) – `loans`

Lending Club'ın **sonuçlanmış** kredilerinden oluşan temiz tablo (2007–2018).
`data/processed/loans_clean.parquet` dosyasında ve PostgreSQL'de `loans` tablosunda bulunur.

- **Satır:** 1.347.698 (her satır bir kredi)
- **Kolon:** 30
- **Kaynak:** [Lending Club Loan Data – Kaggle](https://www.kaggle.com/datasets/wordsforthewise/lending-club)

**Kolon türleri**
- **Başvuru (Origination):** Kredi verilirken bilinen bilgi. Analizde ve modelde güvenle kullanılabilir.
- **Sonuç (Outcome):** Sadece kredi bittikten sonra bilinen bilgi. Sadece kayıp analizinde kullanılır, **modele asla girdi olarak verilmez** (veri sızıntısı).
- **Türetilmiş (Derived):** Temizlik sırasında oluşturulan kolon.

## Kimlik ve tarihler

| Kolon | SQL tipi | Tür | Açıklama |
| --- | --- | --- | --- |
| `id` | BIGINT | Başvuru | Lending Club'ın tekil kredi numarası (birincil anahtar) |
| `issue_date` | DATE | Türetilmiş | Kredinin verildiği ay, ayın 1'i olarak saklanır (örn. 2015-12-01) |
| `issue_year` | SMALLINT | Türetilmiş | Kredinin verildiği yıl (2007–2018) |
| `issue_quarter` | VARCHAR | Türetilmiş | Kredinin verildiği çeyrek, örn. `2015Q4`. Vintage analizinde kullanılır |

## Kredi

| Kolon | SQL tipi | Tür | Açıklama |
| --- | --- | --- | --- |
| `loan_amnt` | NUMERIC | Başvuru | Başvurulan kredi tutarı, USD (500 – 40.000) |
| `term_months` | SMALLINT | Türetilmiş | Vade (ay): 36 veya 60 |
| `int_rate` | NUMERIC | Başvuru | Yıllık faiz oranı, yüzde (örn. 13,56) |
| `installment` | NUMERIC | Başvuru | Borçlunun ödeyeceği aylık taksit, USD |
| `grade` | CHAR(1) | Başvuru | Lending Club'ın risk notu: A (en düşük risk) – G (en yüksek risk) |
| `sub_grade` | VARCHAR | Başvuru | Daha ayrıntılı risk notu: A1 – G5 |
| `purpose` | VARCHAR | Başvuru | Borçlunun belirttiği kredi amacı, örn. `debt_consolidation` (borç birleştirme), `credit_card` (kredi kartı borcu), `small_business` (küçük işletme) |

## Borçlu

| Kolon | SQL tipi | Tür | Açıklama |
| --- | --- | --- | --- |
| `emp_length` | VARCHAR | Başvuru | Çalışma süresi (metin): `< 1 year`, `1 year` … `10+ years` veya `Unknown` (belirtilmemiş) |
| `emp_length_years` | SMALLINT | Türetilmiş | Çalışma süresi (sayı), 0–10 (`< 1 year` = 0, `10+ years` = 10). `Unknown` ise boş (NULL) |
| `home_ownership` | VARCHAR | Başvuru | Konut durumu: `RENT` (kira), `OWN` (ev sahibi), `MORTGAGE` (konut kredili), `OTHER` (diğer; ANY / NONE / OTHER birleştirildi) |
| `annual_inc` | NUMERIC | Başvuru | Borçlunun beyan ettiği yıllık gelir, USD (temizlikten sonra ≥ 1.000) |
| `verification_status` | VARCHAR | Başvuru | Gelirin doğrulanıp doğrulanmadığı: `Not Verified` (doğrulanmadı), `Source Verified` (gelir kaynağı doğrulandı), `Verified` (doğrulandı) |
| `addr_state` | CHAR(2) | Başvuru | Borçlunun yaşadığı ABD eyaleti, iki harfli kod |

## Kredi geçmişi (başvuru anında)

| Kolon | SQL tipi | Tür | Açıklama |
| --- | --- | --- | --- |
| `dti` | NUMERIC | Başvuru | Borç/gelir oranı, yüzde: aylık borç ödemeleri (konut kredisi ve bu kredi hariç) ÷ aylık gelir. Geçersizse (< 0 veya > 100) boş |
| `fico_range_low` | SMALLINT | Başvuru | Borçlunun FICO kredi skoru aralığının alt sınırı |
| `fico_range_high` | SMALLINT | Başvuru | Borçlunun FICO kredi skoru aralığının üst sınırı |
| `fico_avg` | NUMERIC | Türetilmiş | FICO aralığının orta noktası: (alt + üst) / 2 |
| `revol_util` | NUMERIC | Başvuru | Döner kredi kullanım oranı, yüzde: kredi kartı borcunun kart limitine oranı. 150'den büyükse boş |
| `open_acc` | SMALLINT | Başvuru | Açık kredi hesabı sayısı (kartlar, krediler vb.) |
| `delinq_2yrs` | SMALLINT | Başvuru | Son 2 yılda 30 günden fazla geciken ödeme sayısı |
| `inq_last_6mths` | SMALLINT | Başvuru | Son 6 ayda yapılan kredi sorgusu sayısı (sık kredi başvurusu yapıldığını gösterir) |

## Sonuç (kredi bittikten sonra bilinen; modele girdi olarak verilmez)

| Kolon | SQL tipi | Tür | Açıklama |
| --- | --- | --- | --- |
| `loan_status` | VARCHAR | Sonuç | Kredinin son durumu: `Fully Paid` (tamamen ödendi), `Charged Off` (zarar yazıldı), `Default` (temerrüt) veya "Does not meet the credit policy" türevleri |
| `is_default` | SMALLINT | Türetilmiş | Hedef değişken: 1 = Charged Off / Default (battı), 0 = Fully Paid (ödendi) |
| `total_pymnt` | NUMERIC | Sonuç | Borçludan alınan toplam para, USD (anapara + faiz + ücretler + tahsilatlar) |
| `recoveries` | NUMERIC | Sonuç | Kredi zarar yazıldıktan sonra yapılan tahsilat, USD |
| `net_loss` | NUMERIC | Türetilmiş | Nakit kaybı: batan kredilerde `loan_amnt − total_pymnt` (en az 0), ödenen kredilerde 0 |

## Eksik değerler

| Kolon | Eksik | Nedeni |
| --- | --- | --- |
| `emp_length_years` | 78.178 | Çalışma süresi belirtilmemiş (`emp_length` = `Unknown`) |
| `revol_util` | 912 | Kaynak veride boş veya mantıksız değer (> 150) temizlendi |
| `dti` | 516 | Kaynak veride boş veya geçersiz değer (< 0 ya da > 100) temizlendi |
| `open_acc`, `delinq_2yrs`, `inq_last_6mths` | 25–26 | Kaynak veride boş (eski krediler) |

Eksik değerler temiz tabloda **bilerek doldurulmadı**. Doldurma işlemi model notebook'unda, sadece eğitim verisi kullanılarak yapılacak.
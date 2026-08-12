<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="java.sql.*, java.util.*, uz.fido_biznes.cms.*" %>
<%@ page import="oracle.sql.*, oracle.jdbc.*" %>

<%@ taglib uri="/WEB-INF/cms.tld" prefix="t" %>
<jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session"/>
<jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session"/>
<jsp:useBean id="user" class="iabs.User" scope="session"/>

<%
    Connection conn = cods.getConnection();

    if (conn == null || user.getUserCode() == null) {
        pageContext.setAttribute(
                Resource.SESSION_EXPIRED,
                Boolean.TRUE
        );
    }

    Language lang = new Language(
            user.getLanguageIndex(),
            sentences
    );

    pageContext.setAttribute(
            Resource.STR_LANGUAGE,
            lang
    );
%>


<t:page>


    <t:form title="<%=si_title%>"
            minWidth="fill"
            minHeight="fill">


        <script>

            function beforeSave() {
a
                /*
                 * Bu yerda save oldidan tekshiruvlar yoziladi.
                 */

                return true;
            }


            function clearExternalData() {

                fm.pinfl.value = "";
                fm.birth_date.value = "";
                fm.doc_series.value = "";
                fm.doc_number.value = "";

            }


            function identifyFromDpm() {

                /*
                 * DPM API / request logikasi
                 * keyin shu yerga qo'yiladi.
                 */

            }


            function selectTab(tabName) {

                document.getElementById("main_tab").style.display = "none";
                document.getElementById("document_tab").style.display = "none";
                document.getElementById("address_tab").style.display = "none";
                document.getElementById("contact_tab").style.display = "none";
                document.getElementById("bank_tab").style.display = "none";

                if (tabName == "main") {
                    document.getElementById("main_tab").style.display = "";
                }

                if (tabName == "document") {
                    document.getElementById("document_tab").style.display = "";
                }

                if (tabName == "address") {
                    document.getElementById("address_tab").style.display = "";
                }

                if (tabName == "contact") {
                    document.getElementById("contact_tab").style.display = "";
                }

                if (tabName == "bank") {
                    document.getElementById("bank_tab").style.display = "";
                }

            }


            function onLoad() {

                selectTab("main");

            }


            function changeFullName() {

                var lastName = fm.last_name.value || "";
                var firstName = fm.first_name.value || "";
                var patronymic = fm.patronymic.value || "";

                fm.full_name.value =
                    (lastName + " " +
                        firstName + " " +
                        patronymic).replace(/\s+/g, " ").trim();

            }


            function changeFullNameCyr() {

                var lastName = fm.last_name_cyr.value || "";
                var firstName = fm.first_name_cyr.value || "";
                var patronymic = fm.patronymic_cyr.value || "";

                fm.full_name_cyr.value =
                    (lastName + " " +
                        firstName + " " +
                        patronymic).replace(/\s+/g, " ").trim();

            }

        </script>


        <div id="basepanel"
             class="panel">


            <iframe name="frm"
                    style="display:none">
            </iframe>


            <form name="fm"
                  method="post"
                  target="frm"
                  onsubmit="return beforeSave();">


                <!-- ================================================= -->
                <!-- HIDDEN FIELDS                                     -->
                <!-- ================================================= -->

                <input type="hidden"
                       name="request"
                       value="save">

                <input type="hidden"
                       name="client_id"
                       value="">

                <input type="hidden"
                       name="client_code"
                       value="">

                <input type="hidden"
                       name="external_source"
                       value="DPM">


                <!-- ================================================= -->
                <!-- TASHQI MANBAA                                     -->
                <!-- ================================================= -->

                <table width="100%"
                       cellpadding="5"
                       cellspacing="0">

                    <tr>

                        <td colspan="5">

                            <b>Tashqi manbaa</b>

                        </td>

                    </tr>


                    <tr>

                        <!-- MANBA -->

                        <td width="20%">

                            Manba

                            <br>

                            <input name="source"
                                   value="DPM (Davlat personalizatsiya)"
                                   size="25"
                                   readonly>

                        </td>


                        <!-- PINFL -->

                        <td width="20%">

                            JShShIR (PINFL)
                            <span style="color:red">*</span>

                            <br>

                            <input name="pinfl"
                                   mask="14|0-9"
                                   size="20">

                        </td>


                        <!-- BIRTH DATE -->

                        <td width="20%">

                            Tug'ilgan sanasi

                            <br>

                            <input name="birth_date"
                                   mask="date"
                                   size="20">

                        </td>


                        <!-- DOC SERIES -->

                        <td width="20%">

                            ShTH seriyasi
                            <span style="color:red">*</span>

                            <br>

                            <input name="doc_series"
                                   size="20">

                        </td>


                        <!-- DOC NUMBER -->

                        <td width="20%">

                            ShTH raqami
                            <span style="color:red">*</span>

                            <br>

                            <input name="doc_number"
                                   size="20">

                        </td>

                    </tr>


                    <tr>

                        <td colspan="5">

                            <input type="button"
                                   value="Tozalash"
                                   onclick="clearExternalData();">


                            <input type="button"
                                   value="DPM dan mijozni identifikatsiyalash"
                                   onclick="identifyFromDpm();">

                        </td>

                    </tr>

                </table>


                <br>


                <!-- ================================================= -->
                <!-- TABS                                              -->
                <!-- ================================================= -->

                <table width="100%"
                       cellpadding="5"
                       cellspacing="0">

                    <tr>

                        <td>

                            <input type="button"
                                   value="Mijoz asosiy ma'lumotlari"
                                   onclick="selectTab('main');">

                        </td>


                        <td>

                            <input type="button"
                                   value="ShTH ma'lumotlari"
                                   onclick="selectTab('document');">

                        </td>


                        <td>

                            <input type="button"
                                   value="Manzil ma'lumotlari"
                                   onclick="selectTab('address');">

                        </td>


                        <td>

                            <input type="button"
                                   value="Aloqa ma'lumotlari"
                                   onclick="selectTab('contact');">

                        </td>


                        <td>

                            <input type="button"
                                   value="Bank ma'lumotlari"
                                   onclick="selectTab('bank');">

                        </td>

                    </tr>

                </table>


                <hr>


                <!-- ================================================= -->
                <!-- MIJOZ ASOSIY MA'LUMOTLARI                         -->
                <!-- ================================================= -->

                <div id="main_tab">


                    <table width="100%"
                           cellpadding="5"
                           cellspacing="0">


                        <!-- ========================================= -->
                        <!-- FULL NAME                                  -->
                        <!-- ========================================= -->

                        <tr>

                            <td colspan="3">

                                Familiya Ismi Otasining ismi

                                <br>

                                <input name="full_name"
                                       size="100"
                                       readonly>

                            </td>

                        </tr>


                        <!-- ========================================= -->
                        <!-- LATIN FIO                                  -->
                        <!-- ========================================= -->

                        <tr>

                            <td width="33%">

                                Familiya
                                <span style="color:red">*</span>

                                <br>

                                <input name="last_name"
                                       size="40"
                                       onchange="changeFullName();"
                                       onkeyup="changeFullName();">

                            </td>


                            <td width="33%">

                                Ism
                                <span style="color:red">*</span>

                                <br>

                                <input name="first_name"
                                       size="40"
                                       onchange="changeFullName();"
                                       onkeyup="changeFullName();">

                            </td>


                            <td width="33%">

                                Otasining ismi

                                <br>

                                <input name="patronymic"
                                       size="40"
                                       onchange="changeFullName();"
                                       onkeyup="changeFullName();">

                            </td>

                        </tr>


                        <!-- ========================================= -->
                        <!-- CYRILLIC FIO                               -->
                        <!-- ========================================= -->

                        <tr>

                            <td>

                                Familiya (kirill)

                                <br>

                                <input name="last_name_cyr"
                                       size="40"
                                       onchange="changeFullNameCyr();"
                                       onkeyup="changeFullNameCyr();">

                            </td>


                            <td>

                                Ism (kirill)

                                <br>

                                <input name="first_name_cyr"
                                       size="40"
                                       onchange="changeFullNameCyr();"
                                       onkeyup="changeFullNameCyr();">

                            </td>


                            <td>

                                Otasining ismi (kirill)

                                <br>

                                <input name="patronymic_cyr"
                                       size="40"
                                       onchange="changeFullNameCyr();"
                                       onkeyup="changeFullNameCyr();">

                            </td>

                        </tr>


                        <!-- ========================================= -->
                        <!-- PHYSICAL STATUS / BIRTH PLACE             -->
                        <!-- ========================================= -->

                        <tr>

                            <td>

                                Jismoniy holati

                                <br>

                                <select name="physical_status_cd">

                                    <option value="1">
                                        1 — Tirik
                                    </option>

                                    <option value="2">
                                        2 — Vafot etgan
                                    </option>

                                </select>

                            </td>


                            <td>

                                Tug'ilgan joyi

                                <br>

                                <input name="birth_place"
                                       size="40">

                            </td>


                            <td>

                                Tug'ilgan joy (ID)

                                <br>

                                <input name="birth_place_id"
                                       size="40"
                                       placeholder="Ma'lumotnoma kodi">

                            </td>

                        </tr>


                        <!-- ========================================= -->
                        <!-- COUNTRY / CITIZENSHIP / NATIONALITY       -->
                        <!-- ========================================= -->

                        <tr>

                            <td>

                                Tug'ilgan davlati

                                <br>

                                <input name="birth_country_code"
                                       size="8">

                                <input name="birth_country"
                                       size="25">

                            </td>


                            <td>

                                Fuqaroligi

                                <br>

                                <input name="citizenship"
                                       size="40">

                            </td>


                            <td>

                                Millati

                                <br>

                                <input name="nationality_code"
                                       size="8">

                                <input name="nationality"
                                       size="25">

                            </td>

                        </tr>


                        <!-- ========================================= -->
                        <!-- GENDER / RESIDENT / SECRET                -->
                        <!-- ========================================= -->

                        <tr>

                            <td>

                                Jinsi

                                <br>

                                <select name="gender">

                                    <option value="1">
                                        1 — Erkak
                                    </option>

                                    <option value="2">
                                        2 — Ayol
                                    </option>

                                </select>

                            </td>


                            <td>

                                Rezident

                                <br>

                                <select name="resident">

                                    <option value="1">
                                        1 — Rezident
                                    </option>

                                    <option value="0">
                                        0 — Norezident
                                    </option>

                                </select>

                            </td>


                            <td>

                                Maxfiy so'z

                                <br>

                                <input name="secret_word"
                                       size="40">

                            </td>

                        </tr>


                        <!-- ========================================= -->
                        <!-- SEGMENTS                                   -->
                        <!-- ========================================= -->

                        <tr>

                            <td>

                                Segment kodi

                                <br>

                                <input name="segment_code"
                                       size="40"
                                       readonly>

                            </td>


                            <td>

                                Segmenti

                                <br>

                                <input name="segment_name"
                                       size="40"
                                       readonly>

                            </td>


                            <td>

                                Quyi segmenti

                                <br>

                                <select name="sub_segment">

                                    <option value="">

                                        Mass affluent

                                    </option>

                                </select>

                            </td>

                        </tr>


                    </table>

                </div>


                <!-- ================================================= -->
                <!-- SHTH MA'LUMOTLARI                                -->
                <!-- ================================================= -->

                <div id="document_tab"
                     style="display:none">


                    <table width="100%"
                           cellpadding="5"
                           cellspacing="0">


                        <tr>

                            <td width="33%">

                                Hujjat turi

                                <br>

                                <select name="doc_type_cd">

                                    <option value="">
                                        Tanlang
                                    </option>

                                </select>

                            </td>


                            <td width="33%">

                                Hujjat seriyasi

                                <br>

                                <input name="document_series"
                                       size="30">

                            </td>


                            <td width="33%">

                                Hujjat raqami

                                <br>

                                <input name="document_number"
                                       size="30">

                            </td>

                        </tr>


                        <tr>

                            <td>

                                Berilgan sana

                                <br>

                                <input name="document_date"
                                       mask="date">

                            </td>


                            <td>

                                Amal qilish muddati

                                <br>

                                <input name="document_expire_date"
                                       mask="date">

                            </td>


                            <td>

                                Kim tomonidan berilgan

                                <br>

                                <input name="document_issuer"
                                       size="30">

                            </td>

                        </tr>


                    </table>

                </div>


                <!-- ================================================= -->
                <!-- MANZIL MA'LUMOTLARI                              -->
                <!-- ================================================= -->

                <div id="address_tab"
                     style="display:none">


                    <table width="100%"
                           cellpadding="5"
                           cellspacing="0">


                        <tr>

                            <td width="33%">

                                Viloyat

                                <br>

                                <input name="region_name"
                                       size="40">

                            </td>


                            <td width="33%">

                                Tuman

                                <br>

                                <input name="district_name"
                                       size="40">

                            </td>


                            <td width="33%">

                                Shahar

                                <br>

                                <input name="city"
                                       size="40">

                            </td>

                        </tr>


                        <tr>

                            <td colspan="3">

                                Manzil

                                <br>

                                <input name="address"
                                       size="100">

                            </td>

                        </tr>


                    </table>

                </div>


                <!-- ================================================= -->
                <!-- ALOQA MA'LUMOTLARI                               -->
                <!-- ================================================= -->

                <div id="contact_tab"
                     style="display:none">


                    <table width="100%"
                           cellpadding="5"
                           cellspacing="0">


                        <tr>

                            <td width="33%">

                                Mobil telefon

                                <br>

                                <input name="mobile_phone"
                                       size="30">

                            </td>


                            <td width="33%">

                                Uy telefoni

                                <br>

                                <input name="home_phone"
                                       size="30">

                            </td>


                            <td width="33%">

                                E-mail

                                <br>

                                <input name="email"
                                       size="40">

                            </td>

                        </tr>


                    </table>

                </div>


                <!-- ================================================= -->
                <!-- BANK MA'LUMOTLARI                                -->
                <!-- ================================================= -->

                <div id="bank_tab"
                     style="display:none">


                    <table width="100%"
                           cellpadding="5"
                           cellspacing="0">


                        <tr>

                            <td width="33%">

                                Bank

                                <br>

                                <input name="bank_name"
                                       size="40">

                            </td>


                            <td width="33%">

                                Hisob raqami

                                <br>

                                <input name="account_number"
                                       size="40">

                            </td>


                            <td width="33%">

                                Valyuta

                                <br>

                                <select name="currency">

                                    <option value="UZS">
                                        UZS
                                    </option>

                                    <option value="USD">
                                        USD
                                    </option>

                                    <option value="EUR">
                                        EUR
                                    </option>

                                </select>

                            </td>

                        </tr>


                    </table>

                </div>


                <br>


                <!-- ================================================= -->
                <!-- FOOTER                                            -->
                <!-- ================================================= -->

                <table width="100%"
                       cellpadding="5"
                       cellspacing="0">

                    <tr>

                        <td align="left">

                            Проверка дубля:
                            по ПИНФЛ либо по серии
                            и номеру документа

                        </td>


                        <td align="right">

                            <input type="button"
                                   value="<%=lang.get(si_cancel)%>"
                                   onclick="parent.close();">


                            <input type="submit"
                                   value="<%=lang.get(si_save)%>">

                        </td>

                    </tr>

                </table>


            </form>

        </div>


    </t:form>

</t:page>


<!-- ============================================================= -->
<!-- REQUESTS                                                      -->
<!-- ============================================================= -->

<t:requests>


    <!-- ========================================================= -->
    <!-- SAVE                                                      -->
    <!-- ========================================================= -->

    <t:request name="save">

        <%

            try {

                /*
                 * O'ZINGIZNING PROCEDURE'INGIZNI SHU YERGA QO'YASIZ.
                 *
                 * Masalan:
                 *
                 * stored.execRequestProcedure(
                 *     "CL_PHYS_PERSONS_API.EXECUTE_PROCESS",
                 *     request
                 * );
                 *
                 */

                out.print(
                        "<script>" +
                                "parent.returnValue=true;" +
                                "parent.close();" +
                                "</script>"
                );

            } catch (Exception ex) {

                response.setHeader(
                        "RT",
                        "alert"
                );

                Util.alertUserMessage(
                        ex,
                        out
                );

                out.print(
                        "<script>" +
                                "parent.pageLock(false);" +
                                "</script>"
                );

            }

        %>

    </t:request>


    <!-- ========================================================= -->
    <!-- DPM IDENTIFICATION                                       -->
    <!-- ========================================================= -->

    <t:request name="identify_dpm">

        <%

            try {

                /*
                 * DPM API logikasi shu yerga yoziladi.
                 *
                 * request parametrlar:
                 *
                 * pinfl
                 * birth_date
                 * doc_series
                 * doc_number
                 *
                 * Natijada:
                 *
                 * last_name
                 * first_name
                 * patronymic
                 * last_name_cyr
                 * first_name_cyr
                 * patronymic_cyr
                 * birth_place
                 * citizenship
                 * nationality
                 * va boshqalar
                 *
                 * formaga qaytariladi.
                 */

            } catch (Exception ex) {

                response.setHeader(
                        "RT",
                        "error"
                );

                out.print(
                        Util.getUserMessage(ex)
                );

            }

        %>

    </t:request>


</t:requests>


<!-- ============================================================= -->
<!-- LANGUAGE                                                      -->
<!-- ============================================================= -->

<%!
    static final int si_title = SI("Создание клиента", "Мижоз яратиш", "Mijoz yaratish", "Create client");
    static final int si_save = SI("Сохранить", "Са&#1179;лаш", "Saqlash", "Save");
    static final int si_cancel = SI("Отмена", "Бекор ?илиш", "Bekor qilish", "Cancel");
    static final int si_success = SI("Успешно выполнено!", "Муваффа&#1178;иятли бажарилди!", "Muvaffaqiyatli bajarildi!", "Successfully executed!");
    static final int si_error = SI("Ошибка!", "Хатолик!", "Xatolik!", "Error!");

    static final int si_main_info = SI("Основные данные клиента", "Мижоз асосий маълумотлари", "Mijoz asosiy ma'lumotlari", "Client main information");
    static final int si_document_info = SI("Данные ШТХ", "ШТХ маълумотлари", "ShTH ma'lumotlari", "Document information");
    static final int si_address_info = SI("Адресные данные", "Манзил маълумотлари", "Manzil ma'lumotlari", "Address information");
    static final int si_contact_info = SI("Контактные данные", "Ало?а маълумотлари", "Aloqa ma'lumotlari", "Contact information");
    static final int si_bank_info = SI("Банковские данные", "Банк маълумотлари", "Bank ma'lumotlari", "Bank information");

    static final int si_external_source = SI("Внешний источник", "Таш?и манба", "Tashqi manbaa", "External source");
    static final int si_last_name = SI("Фамилия", "Фамилия", "Familiya", "Last name");
    static final int si_first_name = SI("Имя", "Исм", "Ism", "First name");
    static final int si_patronymic = SI("Отчество", "Ота исми", "Otasining ismi", "Patronymic");
    static final int si_birth_date = SI("Дата рождения", "Ту?илган сана", "Tug'ilgan sanasi", "Birth date");
    static final int si_birth_place = SI("Место рождения", "Ту?илган жойи", "Tug'ilgan joyi", "Birth place");
    static final int si_birth_country = SI("Страна рождения", "Ту?илган давлати", "Tug'ilgan davlati", "Birth country");
    static final int si_citizenship = SI("Гражданство", "Фу?аролиги", "Fuqaroligi", "Citizenship");
    static final int si_nationality = SI("Национальность", "Миллати", "Millati", "Nationality");
    static final int si_gender = SI("Пол", "Жинси", "Jinsi", "Gender");
    static final int si_resident = SI("Резидент", "Резидент", "Rezident", "Resident");
    static final int si_secret_word = SI("Секретное слово", "Махфий сўз", "Maxfiy so'z", "Secret word");
    static final int si_segment_code = SI("Код сегмента", "Сегмент коди", "Segment kodi", "Segment code");
    static final int si_segment = SI("Сегмент", "Сегмент", "Segmenti", "Segment");
    static final int si_sub_segment = SI("Под-сегмент", "?уйи сегмент", "Quyi segmenti", "Sub-segment");
%>


<%@ include file="/language.jsp" %>
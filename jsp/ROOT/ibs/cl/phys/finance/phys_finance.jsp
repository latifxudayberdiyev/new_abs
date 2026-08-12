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
        pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
    }
    Language lang = new Language(user.getLanguageIndex(), sentences);
    pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
%>
<t:page>
    <style>
        table{
            width: 100%;
                    }
        td{
            padding: 10px;
            margin: 5px;
            border: solid #E1E8F0 1px;
            border-radius: 5px;
            background-color: #F4F7FB;
            border: none;
            border-collapse: collapse;
        }

    </style>
    <t:form title="<%= si_tittle%>" minWidth="fill" minHeight="fill">

    </t:form>

    <table style="padding: 10px">
        <tr>
            <td>
            <span>
                Oylik daromad
            </span>
                <h3>
                    4,750,000
                </h3>

            </td>
            <td>
            <span>
                Qo'shimcha daromad
            </span>
                <h3>
                    2,500,000
                </h3>

            </td>
            <td>
            <span>
                  Kredit yuki (DTI)
            </span>
                <h3>
                    27 %
                </h3>

            </td>
            <td>
            <span>
               Kredit reytingi
            </span>
                <h3>
                        720
                </h3>

            </td>
        </tr>
        <tr>
            <tr>
                <td COLSPAN="2">
                    Ish joylari
                </td>
                <td>
                    <button>+ Ish joyi qo'shish</button>
                </td>
           </tr>
        <tr>
            <td>
                <label>Tashkilot nomi</label>
                <input type="text" value="IIB tizimi MChJ">
            </td>
            <td>
                <label>Bo'lim</label>
                <input type="text" value="Kredit bo'limi">
            </td>
            <td>
                <label>Lavozim</label>
                <input type="text" placeholder="Lavozim">
            </td>
        </tr>
        <tr>
            <td>
                <label>STIR</label>
                <input type="text" placeholder="9 ta raqam">
            </td>
            <td>
                <label>Ish staji</label>
                <select>
                    <option>
                        1-5 yil
                    </option>
                    <option>
                        5-10 yil
                    </option>
                    <option>
                        10+ yil
                    </option>
                </select>
            </td>
            <td>
                <lable>Tashkilot shakli</lable>
                <select>
                    <option>
                        Bank
                    </option>
                    <option>
                        Davlat korxonasi
                    </option>
                    <option>
                        MCHJ
                    </option>
                    <option>
                        AJ
                    </option>
                </select>
            </td>
        </tr>
        </tr>

        <tr>
        <tr><td colspan="3">Daromad ma'lumotlari</td></tr>
        <tr>
            <td>
                <div>
                    <label>Oylik maosh</label>
                    <input type="text" value="4,750,00">
                </div>
                <div>
                    <label>
                        Olish usuli:
                    </label>
                    <select>
                        <option>
                            Bank kartasi

                        <option>
                            Naqd
                        </option>
                    </select>
                </div>
            </td>
            <td>
                <div>
                    <label>Jami daromad</label>
                    <input type="text" value="7,250,000 so'm">
                </div>
                <div>
                    <label>
                        DTI
                    </label>
                    <b>27% Ч Maqbul</b>
                </div>
            </td>
        </tr>
        </tr>

        <tr>
        <tr><td colspan="3">
        &#9735; Qo'shimcha daromad manbaalari
    </td>
        <td><button><span>&#10011;</span> Qo'shimcha daromad qo'shish</button></td></tr>
        </tr>
        <tr>
            <td colspan="4">
                <p>
                    <span>&#9735;</span>
                        Qo'shimcha daromad manbai
                </p>
                <div>
                    <label>
                        Manba
                    </label>
                    <select>
                        <option>Ijara daromadi</option>
                        <option>Freelance</option>
                        <option>Dvidend</option>
                        <option>Boshqa</option>
                    </select>
                </div>
                <div>
                    <input type="text">
                </div>
                <div>
                    <input type="text">
                </div>
            </td>
        </tr>
    </table>
    <div>
        <button>Bekor qilish</button>
        <button>Saqlash</button>
    </div>

</t:page>
<%!
    static final int si_tittle = SI("‘изическое лицо Ч –еестр клиентов", "search", "Qidiruv:", "Search:");
    static final int si_edit = SI("O'zgartirish", "»зменить", "O'zgartirish", "Edit");
    static final int si_history = SI("O'zgarishlar tarixi", "»стори€ изменений", "O'zgarishlar tarixi", "History");
%>
<%@ include file="/language.jsp" %>
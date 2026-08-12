----------------------------------------------------------------------------------------------------
--  cbr_bank.STATE manba faylida to'liq NULL bo'lib chiqqan edi (ACTIVE ustunida esa haqiqiy
--  A/Z qiymati bor) - xuddi cbr_form_property'da uchragan xatolik kabi. Natijada JSP
--  katalogida 12-spravochnik (Banklar) barcha qatorlarda "Passiv" bo'lib ko'rinar edi.
--  STATE'ni ACTIVE'dan sinxronlaymiz.
----------------------------------------------------------------------------------------------------
update cbr_bank set state = active where state is null;
commit;

select nvl(state,'<NULL>') state, count(*) from cbr_bank group by state;
exit;

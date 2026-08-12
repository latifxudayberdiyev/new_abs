<%
	/* Formalar o'zini chaqirgan sahifaga post qilishi kerak (error.jsp yoki error2.jsp).
	   Static include bo'lgani uchun getServletPath() chaqiruvchi sahifani qaytaradi. */
	String _notesPage = request.getServletPath();
	int    _notesSlash = _notesPage.lastIndexOf('/');
	if (_notesSlash >= 0) _notesPage = _notesPage.substring(_notesSlash + 1);
%>
<script>
	/* Maydon raqamlari chaqiruvchi sahifada belgilanishi mumkin:
	   - error.jsp  -> t:field tegidagi id qiymatlari (18 / 2)
	   - error2.jsp -> core_grid_fields.FIELD_ORDER qiymatlari
	   Belgilanmagan bo'lsa, eski error.jsp qiymatlari ishlatiladi. */
	var NOTES_FO_ERROR_ID     = (typeof FO_ERROR_ID     !== 'undefined') ? FO_ERROR_ID     : 18;
	var NOTES_FO_MESSAGE_CODE = (typeof FO_MESSAGE_CODE !== 'undefined') ? FO_MESSAGE_CODE : 2;

	function fixNote() {
		if (!getDOM("bFixNote").disabled) {
			var errorId      = getData(NOTES_FO_ERROR_ID);
			var messageCode  = getData(NOTES_FO_MESSAGE_CODE);
			if (!errorId) {
				alert('<%=lang.get(si_select_row)%>');
				return;
			}
			document.getElementById('fnErrorId').value     = errorId;
			document.getElementById('fnMessageCode').value = messageCode;
			document.getElementById('fnNoteText').value    = '';
			document.getElementById('fnInfoText').innerHTML = messageCode + ' (ID: ' + errorId + ')';
			document.getElementById('fixNoteOverlay').className = 'fix-note-overlay active';
			document.getElementById('fnNoteText').focus();
		}
	}

	function closeFixNote() {
		document.getElementById('fixNoteOverlay').className = 'fix-note-overlay';
	}

	function saveFixNote() {
		var errorId  = document.getElementById('fnErrorId').value;
		var noteText = document.getElementById('fnNoteText').value;
		if (!noteText || noteText.trim() === '') {
			alert('<%=lang.get(si_note_required)%>');
			return;
		}
		document.getElementById('fnSubmitErrorId').value  = errorId;
		document.getElementById('fnSubmitNoteText').value = noteText;
		document.getElementById('fixNoteForm').submit();
		closeFixNote();
	}

	var currentNotesErrorId = null;
	function openNotesPanel(errorId) {
		currentNotesErrorId = errorId;
		document.getElementById('notesPanelOverlay').className = 'notes-panel-overlay active';
		document.getElementById('notesPanel').className = 'notes-panel active';
		document.getElementById('notesPanelBody').innerHTML = '<div class="note-empty"><%=lang.get(si_loading)%></div>';
		document.getElementById('notesErrorId').value = errorId;
		document.getElementById('notesForm').submit();
	}
	function closeNotesPanel() {
		document.getElementById('notesPanelOverlay').className = 'notes-panel-overlay';
		document.getElementById('notesPanel').className = 'notes-panel';
	}
	function reactNote(noteId, reaction) {
		document.getElementById('reactionNoteId').value = noteId;
		document.getElementById('reactionValue').value  = reaction;
		document.getElementById('reactionForm').submit();
	}
	function onReactionSaved() {
		if (currentNotesErrorId !== null) {
			document.getElementById('notesErrorId').value = currentNotesErrorId;
			document.getElementById('notesForm').submit();
		}
	}
	/* Foydalanuvchi ismi bo'yicha rangli aylana (avatar) - module-pill bilan bir xil palitra */
	var avatarColorMap = {};
	var avatarColorIdx = 0;
	function getAvatarColors(name) {
		if (!avatarColorMap[name]) {
			avatarColorMap[name] = modulePillPalette[avatarColorIdx % modulePillPalette.length];
			avatarColorIdx++;
		}
		return avatarColorMap[name];
	}
	function getInitials(name) {
		if (!name) return '?';
		var parts = name.trim().split(/\s+/).filter(Boolean);
		if (parts.length === 0) return '?';
		if (parts.length === 1) return parts[0].substring(0, 2).toUpperCase();
		return (parts[0].charAt(0) + parts[1].charAt(0)).toUpperCase();
	}

	function onNotesLoaded(list) {
		var body = document.getElementById('notesPanelBody');
		body.innerHTML = '';
		if (!list || !list.length) {
			body.innerHTML = '<div class="note-empty"><%=lang.get(si_no_notes)%></div>';
			return;
		}
		list.forEach(function(n) {
			var item = document.createElement('div');
			item.className = 'note-item';
			var text = document.createElement('div');
			text.className = 'note-item-text';
			text.textContent = n.note_text || '';

			var authorName = n.created_by_name || n.created_by || '';
			var colors = getAvatarColors(authorName);

			var author = document.createElement('div');
			author.className = 'note-item-author';
			var avatar = document.createElement('span');
			avatar.className = 'note-avatar';
			avatar.style.background = colors[0];
			avatar.style.color = colors[1];
			avatar.textContent = getInitials(authorName);
			var nameSpan = document.createElement('span');
			nameSpan.className = 'note-author-name';
			nameSpan.textContent = authorName;
			author.appendChild(avatar);
			author.appendChild(nameSpan);

			var dateSpan = document.createElement('span');
			dateSpan.className = 'note-item-date';
			dateSpan.textContent = n.created_on || '';

			var meta = document.createElement('div');
			meta.className = 'note-item-meta';
			meta.appendChild(author);
			meta.appendChild(dateSpan);

			var reactions = document.createElement('div');
			reactions.className = 'note-item-reactions';

			var likeBtn = document.createElement('button');
			likeBtn.type = 'button';
			likeBtn.className = 'note-reaction-btn like' + (n.my_reaction === 'L' ? ' active' : '');
			likeBtn.innerHTML = '&#128077; <span>' + (n.likes || 0) + '</span>';
			likeBtn.onclick = (function(id) { return function() { reactNote(id, 'L'); }; })(n.note_id);

			var dislikeBtn = document.createElement('button');
			dislikeBtn.type = 'button';
			dislikeBtn.className = 'note-reaction-btn dislike' + (n.my_reaction === 'D' ? ' active' : '');
			dislikeBtn.innerHTML = '&#128078; <span>' + (n.dislikes || 0) + '</span>';
			dislikeBtn.onclick = (function(id) { return function() { reactNote(id, 'D'); }; })(n.note_id);

			reactions.appendChild(likeBtn);
			reactions.appendChild(dislikeBtn);

			item.appendChild(text);
			item.appendChild(meta);
			item.appendChild(reactions);
			body.appendChild(item);
		});
	}
</script>

<!-- Fix Note Modal -->
<div id="fixNoteOverlay" class="fix-note-overlay">
	<div class="fix-note-box">
		<div class="fix-note-head">
			<span><%=lang.get(si_fix_note_title)%></span>
			<button class="fix-note-close" onclick="closeFixNote();">&#215;</button>
		</div>
		<div class="fix-note-body">
			<div class="fix-note-label"><%=lang.get(si_error_label)%></div>
			<div class="fix-note-info" id="fnInfoText">-</div>
			<div class="fix-note-label"><%=lang.get(si_note_text)%></div>
			<textarea id="fnNoteText" class="fix-note-textarea" placeholder="<%=lang.get(si_note_placeholder)%>"></textarea>
			<input type="hidden" id="fnErrorId"     value="">
			<input type="hidden" id="fnMessageCode" value="">
		</div>
		<div class="fix-note-footer">
			<button class="fix-note-btn cancel" onclick="closeFixNote();"><%=lang.get(si_cancel)%></button>
			<button class="fix-note-btn"        onclick="saveFixNote();"><%=lang.get(si_save)%></button>
		</div>
	</div>
</div>

<!-- Fix Notes Side Panel -->
<div id="notesPanelOverlay" class="notes-panel-overlay" onclick="closeNotesPanel();"></div>
<div id="notesPanel" class="notes-panel">
	<div class="notes-panel-head">
		<span><%=lang.get(si_notes_title)%></span>
		<button class="fix-note-close" onclick="closeNotesPanel();">&#215;</button>
	</div>
	<div class="notes-panel-body" id="notesPanelBody"></div>
</div>

<!-- Fix Note save form -->
<iframe name="fixNoteFrame" style="display:none"></iframe>
<form id="fixNoteForm" method="post" action="<%=_notesPage%>" target="fixNoteFrame" style="display:none">
	<input type="hidden" name="request"      value="save_fix_note">
	<input type="hidden" name="process_code" value="SAVE_FIX_NOTE">
	<input type="hidden" id="fnSubmitErrorId"  name="error_id"  value="">
	<input type="hidden" id="fnSubmitNoteText" name="note_text" value="">
</form>

<!-- Fix Notes list form -->
<iframe name="notesFrame" style="display:none"></iframe>
<form id="notesForm" method="post" action="<%=_notesPage%>" target="notesFrame" style="display:none">
	<input type="hidden" name="request"      value="load_notes">
	<input type="hidden" name="process_code" value="GET_FIX_NOTE">
	<input type="hidden" id="notesErrorId" name="error_id" value="">
</form>

<!-- Note reaction (like/dislike) save form -->
<iframe name="reactionFrame" style="display:none"></iframe>
<form id="reactionForm" method="post" action="<%=_notesPage%>" target="reactionFrame" style="display:none">
	<input type="hidden" name="request"      value="save_reaction">
	<input type="hidden" name="process_code" value="SAVE_NOTE_REACTION">
	<input type="hidden" id="reactionNoteId" name="note_id"  value="">
	<input type="hidden" id="reactionValue"  name="reaction" value="">
</form>

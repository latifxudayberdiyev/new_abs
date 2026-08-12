!function () {
    function e(e) {
        var t = document.createEvent("MouseEvents");
        t.initEvent("click", !0, !1), e.dispatchEvent(t)
    }

    function t(e) {
        var t = document.createEvent("HTMLEvents");
        t.initEvent("change", !0, !1), e.dispatchEvent(t)
    }

    function i(e) {
        var t = document.createEvent("FocusEvent");
        t.initEvent("focusin", !0, !1), e.dispatchEvent(t)
    }

    function s(e) {
        var t = document.createEvent("FocusEvent");
        t.initEvent("focusout", !0, !1), e.dispatchEvent(t)
    }

    function n(e) {
        var t = document.createEvent("UIEvent");
        t.initEvent("modalclose", !0, !1), e.dispatchEvent(t)
    }

    function o(e, t) {
        "invalid" == t ? (r(this.dropdown, "invalid"), a(this.dropdown, "valid")) : (r(this.dropdown, "valid"), a(this.dropdown, "invalid"))
    }

    function d(e, t) {
        return null != e[t] ? e[t] : e.getAttribute(t)
    }

    function l(e, t) {
        return !!e && e.classList.contains(t)
    }

    function r(e, t) {
        if (e) return e.classList.add(t)
    }

    function a(e, t) {
        if (e) return e.classList.remove(t)
    }


    var c = ["", "Поиск", "&#1179;идириш", "Qidirish", "Search"],
        h = ["", "Выбрано", "?Танланган", "Tanlangan", "Selected"],
        p = {data: null, searchable: !1, showSelectedItems: !1, fm: null};

    function u(e, t) {
        if (!(this instanceof u)) return new u(e, t);
        this.el = e, this.config = Object.assign({}, p, t || {}), this.selectedOptions = [], "TD" === this.el.parentElement.tagName && (this.el.parentElement.style.display = "flex"), this.placeholder = d(this.el, "placeholder") || this.config.placeholder || "", this.searchtext = d(this.el, "searchtext") || this.config.searchtext || c[t.lang], this.selectedtext = d(this.el, "selectedtext") || this.config.selectedtext || h[t.lang], this.dropdown = null, this.multiple = d(this.el, "multiple"), this.disabled = d(this.el, "disabled"), this.id = d(this.el, "id"), this.create()
    }

    u.prototype.create = function () {
        this.el.style.display = "none", this.data ? this.processData(this.data) : this.extractData(), this.renderDropdown(), this.bindEvent(), initDOM(this.dropdown)
    }, u.prototype.processData = function (e) {
        var t = [];
        e.forEach((e => {
            t.push({
                data: e,
                attributes: {selected: !!e.selected, disabled: !!e.disabled, optgroup: "optgroup" == e.value}
            })
        })), this.options = t
    }, u.prototype.extractData = function () {
        var e = this.el.querySelectorAll("option,optgroup"), t = [], i = [], s = [];
        e.forEach((e => {
            if (!this.multiple || e.innerText) {
                if ("OPTGROUP" == e.tagName) var s = {text: e.label, value: "optgroup"}; else {
                    let t = e.innerText;
                    null != e.dataset.display && (t = e.dataset.display);
                    s = {
                        text: t,
                        value: e.value,
                        extra: e.dataset.extra,
                        selected: e.selected,
                        disabled: null != e.getAttribute("disabled")
                    }
                }
                var n = {
                    selected: e.selected,
                    disabled: null != e.getAttribute("disabled"),
                    optgroup: "OPTGROUP" == e.tagName
                };
                t.push(s), i.push({data: s, attributes: n})
            }
        })), this.data = t, this.options = i, this.options.forEach((e => {
            e.attributes.selected && s.push(e)
        })), this.config.searchable = this.options.length > 15, this.selectedOptions = s
    }, u.prototype.renderDropdown = function () {
        var e = ["iabs-select", (theme && theme === "light") ? "light" : "dark-light", d(this.el, "class") || "", this.disabled ? "disabled" : "", this.multiple ? "has-multiple" : ""];
        let t = '<div class="iabs-select-search-box">';
        t += `<input type="text" class="iabs-select-search" placeholder="${this.searchtext}..." title="search" r="0"/>`, t += "</div>";
        var i = `<div id="${this.id}" name="${this.id}" class="${e.join(" ")}" tabindex="${this.disabled ? null : 0}">`;
        i += `<span class="${this.multiple ? "multiple-options" : "current"}"></span>`, i += '<div class="iabs-select-dropdown">', i += `${this.config.searchable ? t : ""}`, i += '<ul class="list"></ul>', i += "</div>", i += "</div>", this.el.insertAdjacentHTML("afterend", i), this.dropdown = this.el.nextElementSibling, this._renderSelectedItems(), this._renderItems()
    }, u.prototype._renderSelectedItems = function () {
        if (this.multiple) {
            var e = "";
            this.config.showSelectedItems || this.config.showSelectedItems || "auto" == window.getComputedStyle(this.dropdown).width || this.selectedOptions.length < 2 ? (this.selectedOptions.forEach((function (t) {
                e += `<span class="current">${t.data.text}</span>`
            })), e = "" == e ? this.placeholder : e) : e = this.selectedOptions.length + " " + this.selectedtext, this.dropdown.querySelector(".multiple-options").innerHTML = e
        } else {
            var t = this.selectedOptions.length > 0 ? this.selectedOptions[0].data.text : this.placeholder;
            this.dropdown.querySelector(".current").innerHTML = t
        }
    }, u.prototype._renderItems = function () {
        var e = this.dropdown.querySelector("ul");
        this.options.forEach((t => {
            e.appendChild(this._renderItem(t))
        }))
    }, u.prototype._renderItem = function (e) {
        var t = document.createElement("li");
        if (this.multiple) {
            var i = document.createElement("input");
            i.type = "checkbox", i.checked = e.attributes.selected, i.addEventListener("click", (s => {
                s.stopPropagation(), i.checked = !i.checked, this._onItemClicked(e, t)
            })), t.appendChild(i)
        }
        var s = document.createElement("span");
        if (s.textContent = e.data.text, t.appendChild(s), null != e.data.extra && t.appendChild(this._renderItemExtra(e.data.extra)), e.attributes.optgroup) r(t, "optgroup"); else {
            t.setAttribute("data-value", e.data.value);
            var n = ["option", e.attributes.selected ? "selected" : null, e.attributes.disabled ? "disabled" : null];
            t.onclick = () => {
                this._onItemClicked(e, t)
            }, t.classList.add(...n)
        }
        return e.element = t, t
    }, u.prototype._renderItemExtra = function (e) {
        var t = document.createElement("span");
        return t.innerHTML = e, r(t, "extra"), t
    }, u.prototype.update = function () {
        if (this.extractData(), this.dropdown) {
            var t = l(this.dropdown, "open");
            this.dropdown.parentNode.removeChild(this.dropdown), this.create(), t && e(this.dropdown)
        }
        d(this.el, "disabled") ? this.disable() : this.enable()
    }, u.prototype.disable = function () {
        this.disabled || (this.disabled = !0, r(this.dropdown, "disabled"))
    }, u.prototype.enable = function () {
        this.disabled && (this.disabled = !1, a(this.dropdown, "disabled"))
    }, u.prototype.clear = function () {
        this.resetSelectValue(), this.selectedOptions = [], this._renderSelectedItems(), this.update(), t(this.el)
    }, u.prototype.destroy = function () {
        this.dropdown && (this.dropdown.parentNode.removeChild(this.dropdown), this.el.style.display = "")
    }, u.prototype.bindEvent = function () {
        this.dropdown.addEventListener("click", this._onClicked.bind(this)), this.dropdown.addEventListener("keydown", this._onKeyPressed.bind(this)), this.dropdown.addEventListener("focusin", i.bind(this, this.el)), this.dropdown.addEventListener("focusout", s.bind(this, this.el)), this.el.addEventListener("invalid", o.bind(this, this.el, "invalid")), this.config.fm.addEventListener("click", this._onClickedOutside.bind(this)), this.config.searchable && this._bindSearchEvent()
    }, u.prototype._bindSearchEvent = function () {
        var e = this.dropdown.querySelector(".iabs-select-search");
        e && e.addEventListener("click", (function (e) {
            return e.stopPropagation(), !1
        })), e.addEventListener("input", this._onSearchChanged.bind(this))
    }, u.prototype._onClicked = function (e) {
        var t, i;
        if (e.preventDefault(), l(this.dropdown, "open") ? this.multiple ? e.target == this.dropdown && (a(this.dropdown, "open"), n(this.el)) : (a(this.dropdown, "open"), n(this.el)) : (r(this.dropdown, "open"), t = this.el, (i = document.createEvent("UIEvent")).initEvent("modalopen", !0, !1), t.dispatchEvent(i)), l(this.dropdown, "open")) {
            var s = this.dropdown.querySelector(".iabs-select-search");
            s && (s.value = "", s.focus());
            var o = this.dropdown.querySelector(".focus");
            a(o, "focus"), r(o = this.dropdown.querySelector(".selected"), "focus"), this.dropdown.querySelectorAll("ul li").forEach((function (e) {
                e.style.display = ""
            }))
        } else this.dropdown.focus()
    }, u.prototype._onItemClicked = function (e, t) {
        this.checkbox = null, this.multiple && (this.checkbox = t.querySelector('input[type="checkbox"]')), l(t, "disabled") || (this.multiple ? l(t, "selected") ? (a(t, "selected"), this.multiple && this.checkbox && (this.checkbox.checked = !1), this.selectedOptions = this.selectedOptions.filter((t => t !== e)), this.el.querySelector(`option[value="${t.dataset.value}"]`).selected = !1) : (r(t, "selected"), this.multiple && this.checkbox && (this.checkbox.checked = !0), this.selectedOptions.push(e), this.el.querySelector(`option[value="${t.dataset.value}"]`).selected = !0) : (this.selectedOptions.forEach((function (e) {
            a(e.element, "selected")
        })), this.multiple && this.checkbox && (this.checkbox.checked = !0), r(t, "selected"), this.selectedOptions = [e]), this._renderSelectedItems(), this.updateSelectValue())
    }, u.prototype.updateSelectValue = function () {
        if (this.multiple) {
            var e = this.el;
            this.selectedOptions.forEach((function (t) {
                var i = e.querySelector(`option[value="${t.data.value}"]`);
                i && i.setAttribute("selected", !0)
            }))
        } else this.selectedOptions.length > 0 && (this.el.value = this.selectedOptions[0].data.value);
        t(this.el)
    }, u.prototype.resetSelectValue = function () {
        if (this.multiple) {
            var e = this.el;
            this.selectedOptions.forEach((function (t) {
                var i = e.querySelector(`option[value="${t.data.value}"]`);
                i && i.removeAttribute("selected")
            }))
        } else this.selectedOptions.length > 0 && (this.el.selectedIndex = -1);
        t(this.el)
    }, u.prototype._onClickedOutside = function (e) {
        this.dropdown.contains(e.target) || (a(this.dropdown, "open"), n(this.el))
    }, u.prototype._onKeyPressed = function (t) {
        var i = this.dropdown.querySelector(".focus"), s = l(this.dropdown, "open");
        if (13 == t.keyCode) e(s ? i : this.dropdown); else if (40 == t.keyCode) {
            if (s) {
                var n = this._findNext(i);
                if (n) a(this.dropdown.querySelector(".focus"), "focus"), r(n, "focus")
            } else e(this.dropdown);
            t.preventDefault()
        } else if (38 == t.keyCode) {
            if (s) {
                var o = this._findPrev(i);
                if (o) a(this.dropdown.querySelector(".focus"), "focus"), r(o, "focus")
            } else e(this.dropdown);
            t.preventDefault()
        } else if (27 == t.keyCode && s) e(this.dropdown); else if (32 === t.keyCode && s) return !1;
        return !1
    }, u.prototype._findNext = function (e) {
        for (e = e ? e.nextElementSibling : this.dropdown.querySelector(".list .option"); e;) {
            if (!l(e, "disabled") && "none" != e.style.display) return e;
            e = e.nextElementSibling
        }
        return null
    }, u.prototype._findPrev = function (e) {
        for (e = e ? e.previousElementSibling : this.dropdown.querySelector(".list .option:last-child"); e;) {
            if (!l(e, "disabled") && "none" != e.style.display) return e;
            e = e.previousElementSibling
        }
        return null
    }, u.prototype._onSearchChanged = function (e) {
        var t = l(this.dropdown, "open"), i = e.target.value;
        if ("" == (i = i.toLowerCase())) this.options.forEach((function (e) {
            e.element.style.display = ""
        })); else if (t) {
            var s = new RegExp(i);
            this.options.forEach((function (e) {
                var t = e.data.text.toLowerCase(), i = s.test(t);
                e.element.style.display = i ? "" : "none"
            }))
        }
        this.dropdown.querySelectorAll(".focus").forEach((function (e) {
            a(e, "focus")
        })), r(this._findNext(null), "focus")
    }, window.IabsSelect = u
}(), Object.defineProperty(window, "IabsSelect", {writable: !1, configurable: !1});
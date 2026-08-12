package uz.sqb.abs.pechat.payload.error;


import uz.sqb.abs.pechat.payload.base.MessageTranslation;

public record ErrorShortDto(MessageTranslation message, boolean formattable) {
}

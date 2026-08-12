package uz.sqb.abs.pechat.configuration.security;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.List;


public record SecurityUserDetails(String id, String clientId, String clientSecret,
                                  Collection<? extends GrantedAuthority> authorities) implements UserDetails {

    public SecurityUserDetails(String id, String clientId, String clientSecret, List<String> roles) {
        this(id, clientId, clientSecret, roles.stream().map(SimpleGrantedAuthority::new).toList());
    }

    @Override
    public String getUsername() {
        return this.clientId;
    }

    @Override
    public String getPassword() {
        return this.clientSecret;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return this.authorities;
    }
}

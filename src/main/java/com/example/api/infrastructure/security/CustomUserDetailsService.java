package com.example.api.infrastructure.security;

import com.example.api.domain.model.Usuario;
import com.example.api.application.service.UsuarioService;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
public class CustomUserDetailsService implements UserDetailsService {

    private final UsuarioService usuarioService;

    public CustomUserDetailsService(UsuarioService usuarioService) {
        this.usuarioService = usuarioService;
    }

    @Override
    public UserDetails loadUserByUsername(String email)
            throws UsernameNotFoundException {

        Usuario usuario = usuarioService
                .obtenerPorEmail(email)
                .orElseThrow(() ->
                        new UsernameNotFoundException(
                                "Usuario no encontrado"
                        )
                );

        return User.builder()
                .username(usuario.getEmail())
                .password(usuario.getPassword())
                .roles(usuario.getRol())
                .build();
    }
}
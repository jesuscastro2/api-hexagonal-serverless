package com.example.api.infrastructure.security;

import com.example.api.domain.model.Usuario;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;

@Service
public class JwtService {

    private static final String SECRET_KEY =
            "MiClaveSecretaParaJWT12345678901234567890";

    private static final long EXPIRATION_TIME =
            1000 * 60 * 60; // 1 hora

    private final SecretKey key;

    public JwtService() {
        this.key = Keys.hmacShaKeyFor(
                SECRET_KEY.getBytes(StandardCharsets.UTF_8)
        );
    }

    public String generarToken(Usuario usuario) {

        Date ahora = new Date();
        Date expiracion = new Date(
                ahora.getTime() + EXPIRATION_TIME
        );

        return Jwts.builder()
                .subject(usuario.getEmail())
                .claim("rol", usuario.getRol())
                .issuedAt(ahora)
                .expiration(expiracion)
                .signWith(key)
                .compact();
    }

    public String obtenerEmail(String token) {

        return Jwts.parser()
                .verifyWith(key)
                .build()
                .parseSignedClaims(token)
                .getPayload()
                .getSubject();
    }

    public boolean esTokenValido(String token) {

        try {
            obtenerEmail(token);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}
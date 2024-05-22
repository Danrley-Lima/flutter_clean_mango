Feature: Login
Como cliente, quero poder acessar minha conta e me manter logado
para que eu possa ver e responder enquetes de forma rápida

Cenario: Credenciais validas
Dado que o cliente informou credenciais validas
Quando solicitar para fazer login
Deve enviar o usuario para a tela de pesquisas
E manter o usuario logado

Cenario: Credenciais invalidas
Dado que o cliente informou credenciais invalidas
Quando solicitar para fazer login
Deve retornar mensagem de erro
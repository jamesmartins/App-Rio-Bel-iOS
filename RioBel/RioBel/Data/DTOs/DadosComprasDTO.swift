import Foundation

struct DadosComprasResponseDTO: Codable {
    let msgerro: String
    let coderro: Int
    let cliente: DadosComprasClienteDTO?
    let saldo: DadosComprasSaldoDTO?
    let compras: [DadosComprasMovimentoDTO]?
}

struct DadosComprasClienteDTO: Codable {
    let codigoCliente: Int
    let nome: String
    let primeiroNome: String?
    let numCgcecpf: String
    let cartao: String?
    let email: String?
    let celular: String?
    let ativo: Bool?

    enum CodingKeys: String, CodingKey {
        case codigoCliente = "codigo_cliente"
        case nome
        case primeiroNome = "primeiro_nome"
        case numCgcecpf = "num_cgcecpf"
        case cartao, email, celular, ativo
    }

    func toDomain() -> Cliente {
        Cliente(
            codigoCliente: codigoCliente,
            nome: nome,
            primeiroNome: primeiroNome,
            numCgcecpf: numCgcecpf,
            cartao: cartao,
            email: email,
            celular: celular,
            ativo: ativo
        )
    }
}

struct DadosComprasSaldoDTO: Codable {
    let unidade: String
    let disponivel: Double
    let resgatado: Double
    let expirado: Double
    let ganho: Double?
    let aLiberar: Double?
    let bloqueado: Double?

    enum CodingKeys: String, CodingKey {
        case unidade, disponivel, resgatado, expirado, ganho
        case aLiberar = "a_liberar"
        case bloqueado
    }

    func toDomain() -> Saldo {
        Saldo(
            unidade: unidade,
            disponivel: disponivel,
            resgatado: resgatado,
            expirado: expirado,
            ganho: ganho ?? 0,
            aLiberar: aLiberar ?? 0,
            bloqueado: bloqueado ?? 0
        )
    }
}

struct DadosComprasMovimentoDTO: Codable {
    let codigoMovimento: Int
    let tipoMovimento: String
    let lancamento: String
    let ocorrencia: String
    let unidade: String
    let status: String
    let dataMovimentoBr: String
    let valores: DadosComprasValoresDTO

    enum CodingKeys: String, CodingKey {
        case codigoMovimento = "codigo_movimento"
        case tipoMovimento = "tipo_movimento"
        case lancamento, ocorrencia, unidade, status
        case dataMovimentoBr = "data_movimento_br"
        case valores
    }

    func toDomain() -> MovimentoCompra {
        MovimentoCompra(
            id: codigoMovimento,
            tipoMovimento: tipoMovimento,
            lancamento: lancamento,
            ocorrencia: ocorrencia,
            unidade: unidade,
            status: status,
            dataMovimentoBr: dataMovimentoBr,
            valorVenda: valores.venda,
            valorCashback: valores.cashbackOuPontos
        )
    }
}

struct DadosComprasValoresDTO: Codable {
    let venda: Double
    let cashbackOuPontos: Double

    enum CodingKeys: String, CodingKey {
        case venda
        case cashbackOuPontos = "cashback_ou_pontos"
    }
}

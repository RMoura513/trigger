CREATE DATABASE ex
GO
USE ex
GO
CREATE TABLE Produto (
    Codigo INT PRIMARY KEY,
    Nome VARCHAR(255),
    Descricao VARCHAR(255),
    ValorUnitario DECIMAL(10, 2)
);
GO
CREATE TABLE Estoque (
    CodigoProduto INT PRIMARY KEY,
    QtdEstoque INT,
    EstoqueMinimo INT,
    FOREIGN KEY (CodigoProduto) REFERENCES Produto(Codigo)
);
GO
CREATE TABLE Venda (
    NotaFiscal INT PRIMARY KEY,
    CodigoProduto INT,
    Quantidade INT,
    FOREIGN KEY (CodigoProduto) REFERENCES Produto(Codigo)
);

CREATE TRIGGER TR_Venda_AfterInsert
ON Venda
AFTER INSERT
AS
BEGIN
    DECLARE @CodigoProduto INT, @Quantidade INT, @EstoqueAtual INT, @EstoqueMinimo INT

    SELECT @CodigoProduto = i.CodigoProduto, @Quantidade = i.Quantidade,
           @EstoqueAtual = e.QtdEstoque, @EstoqueMinimo = e.EstoqueMinimo
    FROM inserted i
    INNER JOIN Estoque e ON i.CodigoProduto = e.CodigoProduto

    IF @Quantidade <= @EstoqueAtual
    BEGIN
        UPDATE Estoque
        SET QtdEstoque = QtdEstoque - @Quantidade
        WHERE CodigoProduto = @CodigoProduto
        IF (@EstoqueAtual - @Quantidade) <= @EstoqueMinimo
        BEGIN
            PRINT 'A venda foi realizada e o estoque está abaixo do estoque mínimo!'
        END
        ELSE
        BEGIN
            PRINT 'A venda foi realizada com sucesso!'
        END
    END
    ELSE
    BEGIN
        ROLLBACK;
        PRINT 'Erro: Quantidade indisponível em estoque. Venda cancelada!'
    END
END


CREATE FUNCTION GetVendaDetails(@NotaFiscal INT)
RETURNS TABLE
AS
RETURN
(
    SELECT v.NotaFiscal, v.CodigoProduto, p.Nome, p.Descricao, p.ValorUnitario,
           v.Quantidade, (p.ValorUnitario * v.Quantidade) AS ValorTotal
    FROM Venda v
    INNER JOIN Produto p ON v.CodigoProduto = p.Codigo
    WHERE v.NotaFiscal = @NotaFiscal
)


SELECT * FROM GetVendaDetails(12345);



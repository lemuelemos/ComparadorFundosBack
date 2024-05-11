# Teste da coneção com o DB

test_that("Teste de conexão de pool", {
  # Chama a função pool para obter uma conexão de pool
  pool_conn <- pool()

  # Verifica se a conexão de pool é um objeto de classe 'Pool'
  expect_true(inherits(pool_conn, "Pool"),
              info = "A conexão de pool não é um objeto de classe 'Pool'.")

  # Fecha a conexão de pool após o teste
  pool::poolClose(pool_conn)
})

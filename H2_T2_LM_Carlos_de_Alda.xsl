<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="html" doctype-system="about:legacy-compat" encoding="UTF-8" indent="yes"/>

<xsl:key name="productos_por_trimestre" match="producto" use="concat(ancestor::pedido/anio/@año, ancestor::pedido/trimestre/@numero)" />

<xsl:template match="/">
  <html>
  <head>
    <title>Lista de Pedidos, Clientes, Facturas y Productos Vendidos</title>
    <style>
      table {
        border-collapse: collapse;
        width: 100%;
      }
      th, td {
        border: 1px solid #dddddd;
        text-align: left;
        padding: 8px;
      }
      th {
        background-color: #f2f2f2;
      }
      .most-sold-header {
        margin-top: 20px;
      }
      .most-sold-header h2 {
        margin-bottom: 5px;
      }
      .most-sold-products {
        margin-top: 10px;
      }
      /* Estilos para las facturas */
      .invoice-card {
        border: 1px solid #ccc;
        border-radius: 5px;
        padding: 10px;
        margin-bottom: 20px;
        background-color: #f9f9f9;
        box-shadow: 0 4px 8px 0 rgba(0,0,0,0.2);
        transition: 0.3s;
        width: 50%;
      }
      .invoice-card:hover {
        box-shadow: 0 8px 16px 0 rgba(0,0,0,0.2);
      }
      .invoice-card h3 {
        margin-top: 0;
        color: #333;
        font-size: 20px;
      }
      .invoice-details, .invoice-products {
        margin-bottom: 10px;
        font-size: 16px;
        color: #555;
      }
      .invoice-products {
        margin-left: 20px;
      }
    </style>
  </head>
  <body>
    <h2>Lista de Pedidos</h2>
    <table>
      <tr>
        <th>Nombre</th>
        <th>Apellidos</th>
        <th>Teléfono</th>
        <th>Dirección</th>
        <th>Correo</th>
        <th>Fecha de Compra</th>
        <th>Fecha de Entrega</th>
        <th>Total de la Factura</th>
        <th>Productos</th>
      </tr>
      <xsl:apply-templates select="//pedido" />
    </table>

    <h2>Lista de Clientes</h2>
    <table>
      <tr>
        <th>Nombre</th>
        <th>Apellidos</th>
        <th>Teléfono</th>
        <th>Dirección</th>
        <th>Correo</th>
        <th>Fecha de Inclusión</th>
      </tr>
      <xsl:apply-templates select="//pedido" mode="client" />
    </table>

    <h2>Facturas</h2>
    <xsl:apply-templates select="//pedido" mode="invoice" />

    <h2>Productos Vendidos en el Primer Trimestre de 2021 y Último Trimestre de 2022</h2>
    <table>
      <tr>
        <th>Nombre del Producto</th>
        <th>Unidades Vendidas</th>
      </tr>
      <!-- Aplicamos plantilla para todos los pedidos -->
      <xsl:apply-templates select="//pedido" mode="mostSoldProducts"/>
    </table>

  </body>
  </html>
</xsl:template>

<xsl:template match="pedido">
  <tr>
    <td><xsl:value-of select="nombre" /></td>
    <td><xsl:value-of select="apellidos" /></td>
    <td><xsl:value-of select="telefono" /></td>
    <td>
      <xsl:value-of select="concat(direccion/calle, ', ', direccion/ciudad, ', ', direccion/provincia, ' ', direccion/codigo_postal)" />
    </td>
    <td><xsl:value-of select="correo" /></td>
    <td><xsl:value-of select="pedido_detalle/fecha_compra" /></td>
    <td><xsl:value-of select="pedido_detalle/fecha_entrega" /></td>
    <td><xsl:value-of select="pedido_detalle/total_factura" /></td>
    <td>
      <ul class="product-list">
        <xsl:for-each select="pedido_detalle/productos/producto">
          <li><xsl:value-of select="nombre" /></li>
        </xsl:for-each>
      </ul>
    </td>
  </tr>
</xsl:template>

<xsl:template match="pedido" mode="client">
  <tr>
    <td><xsl:value-of select="nombre" /></td>
    <td><xsl:value-of select="apellidos" /></td>
    <td><xsl:value-of select="telefono" /></td>
    <td>
      <xsl:value-of select="concat(direccion/calle, ', ', direccion/ciudad, ', ', direccion/provincia, ' ', direccion/codigo_postal)" />
    </td>
    <td><xsl:value-of select="correo" /></td>
    <td><xsl:value-of select="fecha_inclusion" /></td>
  </tr>
</xsl:template>

<xsl:template match="pedido" mode="invoice">
  <xsl:variable name="pedido_numero" select="pedido_detalle/numero_pedido" />
  <xsl:variable name="cliente_nombre" select="concat(nombre, ' ', apellidos)" />
  
  <div class="invoice-card">
    <h3>Factura</h3>
    <div class="invoice-details">
      <strong>Número de Pedido:</strong> <xsl:value-of select="$pedido_numero" /><br />
      <strong>Cliente:</strong> <xsl:value-of select="$cliente_nombre" /><br />
      <strong>Dirección de Envío:</strong><br />
      <xsl:value-of select="concat(direccion/calle, ', ', direccion/ciudad, ', ', direccion/provincia, ' ', direccion/codigo_postal)" /><br />
    </div>
    <div class="invoice-products">
      <strong>Productos:</strong><br />
      <xsl:for-each select="pedido_detalle/productos/producto">
        - <xsl:value-of select="nombre" /> (<xsl:value-of select="unidades" /> unidad/es) - <xsl:value-of select="precio * unidades" /> €<br />
      </xsl:for-each>
    </div>
    <strong>Total de la Factura:</strong> <xsl:value-of select="pedido_detalle/total_factura" /> €
  </div>
</xsl:template>

<xsl:template match="pedido" mode="mostSoldProducts">
  <!-- Verificar si el pedido corresponde al primer trimestre de 2021 o al último trimestre de 2022 -->
  <xsl:if test="(anio/@año = '2021' and trimestre/@numero = '1') or (anio/@año = '2022' and trimestre/@numero = '4')">
    <xsl:variable name="productos_vendidos" select="pedido_detalle/productos/producto"/>
    <xsl:for-each select="$productos_vendidos">
      <tr>
        <td><xsl:value-of select="nombre"/></td>
        <td><xsl:value-of select="unidades"/></td>
      </tr>
    </xsl:for-each>
  </xsl:if>
</xsl:template>


</xsl:stylesheet>

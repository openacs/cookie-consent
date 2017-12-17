<master>
<property name="doc(title)">@title;literal@</property>
<property name="context">@context;literal@</property>

<h1>@title;noquote@</h1>
<p>
The current version of the @what@ is @version@.
<if @resources@ not nil><p>This version of the @what@ is installed locally
under <strong>@resources@</strong></if>
<else><p>In the current installation the @what@ is used via CDN <strong>@cdn@</strong>.
  <if @writable@ true>
  <p>Do you want to <a href="download" class="button">download</a>
  version @version@ of @what@ to your file system?</p>
  </if>
  <else>
  <p>The directory <strong>@path@</strong> is NOT writable for the server. In
  order to be able to download the @what@ via this web interface,
  please change the permissions so that OpenACS can write to it.</p>
  </else>
</else>.
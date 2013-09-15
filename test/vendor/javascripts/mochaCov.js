var MochaCov;

MochaCov = (function() {
  function MochaCov() {
    var fileName;
    $(".coverage").remove();
    for (fileName in _$jscoverage) {
      $("#mocha").after(this._buildFileReviewDom(fileName));
    }
  }

  MochaCov.prototype.coveragePercentage = function(fileName) {
    var cov = _.reduce(_$jscoverage[fileName], function(m, n, i) {
      m.covered += n > 0 ? 1 : 0;
      m.total += n !== undefined ? 1 : 0;
      return m;
    }, {
      covered: 0,
      total: 0
    });
    cov.percentage = (cov.covered / cov.total * 100).toFixed(2);
    cov.percentage = cov.percentage.replace(/.0+$/, '');
    return cov;
  };

  MochaCov.prototype._buildFileReviewDom = function(fileName) {
    var $actions, $anchor, $container, $coverage, $info, $meta, $span, $table, $tbody, $toggle, coverageStats;
    coverageStats = this.coveragePercentage(fileName);
    if(+coverageStats.percentage === 100) return;
    $coverage = $("<div>").addClass("coverage");
    if(+coverageStats.percentage !== 100) { $coverage.addClass("not-covered"); };
    $meta = $("<div>").addClass("meta");
    $coverage.append($meta);
    $info = $("<div>").addClass("info");
    $meta.append($info);
    $span = $("<span>").addClass("toggle");
    $info.append($span);
    $anchor = $("<a>").attr("href", "#").text("" + fileName + " " + coverageStats.percentage + "%");
    $span.append($anchor);
    $tableContainer = $("<div>").addClass("table-container hidden");
    $coverage.append($tableContainer);
    $table = $("<table>").addClass("code-table");
    $tableContainer.append($table);
    $tbody = $("<tbody>");
    $table.append($tbody);
    $container = $("tbody", $coverage);
    _.each(_$jscoverage[fileName].source, function(lineOfCode, lineNumber) {
      var $codeCell, $codeLine, $gutterCell, $hitCountCell, $row, hitCount;
      $codeLine = $("<pre>");
      $codeLine.addClass("code-line");
      $codeLine.text(lineOfCode);
      $codeCell = $("<td>").append($codeLine);
      $gutterCell = $("<td>");
      $gutterCell.addClass("line-number");
      $gutterCell.html(lineNumber + 1);
      hitCount = _$jscoverage[fileName][lineNumber + 1];
      $hitCountCell = $("<td>");
      $hitCountCell.addClass("hit-count");
      $hitCountCell.html(hitCount);
      $row = $("<tr>");
      $row.append($gutterCell);
      $row.append($hitCountCell);
      $row.append($codeCell);
      if (hitCount === 0) {
        $row.addClass("warning");
      }
      $row.addClass("line-of-code");
      return $container.append($row);
    });
    $coverage.find(".meta .info .toggle a", $coverage).click(function($event) {
      var newText;
      $event.preventDefault();
      $(".table-container", $coverage).toggleClass("hidden");
      return $(this).text(newText);
    });
    return $coverage;
  };

  return MochaCov;

})();

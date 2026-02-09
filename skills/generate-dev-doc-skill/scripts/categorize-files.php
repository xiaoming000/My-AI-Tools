<?php
/**
 * 按模版分类输出文件路径列表
 * 模版分类：后端模型（包含验证器）、后端仓储、后端服务、后端控制器、前端视图、前端JS、前端CSS、其他文件
 * 用法: php categorize-files.php [工作区路径]  从 stdin 每行读一个路径
 *   或: php categorize-files.php [工作区路径] path1 path2 ...
 * 输出: JSON 对象 { "分类名": ["path1", ...], ... }，键顺序与模版一致
 */

$workspace = getcwd();
$paths = [];

if (isset($argv[1])) {
    if (is_dir($argv[1])) {
        $workspace = $argv[1];
        for ($i = 2; $i < count($argv); $i++) {
            $p = trim($argv[$i]);
            if ($p !== '') {
                $paths[] = $p;
            }
        }
    } else {
        for ($i = 1; $i < count($argv); $i++) {
            $p = trim($argv[$i]);
            if ($p !== '') {
                $paths[] = $p;
            }
        }
    }
}
if (empty($paths)) {
    while (($line = fgets(STDIN)) !== false) {
        $p = trim($line);
        if ($p !== '') {
            $paths[] = $p;
        }
    }
}

$categories = [
    '后端模型' => [],
    '后端仓储' => [],
    '后端服务' => [],
    '后端控制器' => [],
    '前端视图' => [],
    '前端JS' => [],
    '前端CSS' => [],
    '其他文件' => [],
];

foreach ($paths as $path) {
    $normalized = str_replace('\\', '/', $path);
    if (strpos($normalized, '/controller/') !== false) {
        $categories['后端控制器'][] = $path;
    } elseif (strpos($normalized, '/model/') !== false || strpos($normalized, '/validate/') !== false) {
        $categories['后端模型'][] = $path;
    } elseif (strpos($normalized, 'repository') !== false || strpos($normalized, '仓储') !== false) {
        $categories['后端仓储'][] = $path;
    } elseif (strpos($normalized, 'service') !== false || strpos($normalized, '服务') !== false) {
        $categories['后端服务'][] = $path;
    } elseif (strpos($normalized, '/view/') !== false) {
        $categories['前端视图'][] = $path;
    } elseif (preg_match('/\.(js|mjs|cjs)$/i', $path)) {
        $categories['前端JS'][] = $path;
    } elseif (preg_match('/\.(css|less|scss)$/i', $path)) {
        $categories['前端CSS'][] = $path;
    } else {
        $categories['其他文件'][] = $path;
    }
}

// 只输出有文件的分类
$out = [];
foreach ($categories as $name => $list) {
    if (!empty($list)) {
        $out[$name] = $list;
    }
}

echo json_encode($out, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
